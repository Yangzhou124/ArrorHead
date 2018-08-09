//
//  ARRGameViewController.m
//  Arrows
//
//  Created by totaramudu on 09/07/15.
//  Copyright (c) 2015 Deviceworks. All rights reserved.
//

#import "ARRGameViewController.h"
#import "ARRPlaygroundViewController.h"
#import "ARRJoystickViewController.h"
#import "ARRAnalytics.h"
#import <AVOSCloud.h>
#import "ToolLib.h"

const int PLAYGROUND_PERCENTAGE         =   70;

@interface ARRGameViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *joystickHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playgroundHeightConstraint;
@property (nonatomic, weak) ARRGameLogic* gameLogic;
@property (nonatomic) ARRJoystickViewController* joystickVC;
@property (nonatomic) ARRPlaygroundViewController* playgroundVC;
@end

@implementation ARRGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self resizeSubviews];
    [self preparePlaygroundAndStartGame];
    [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:@"Refer"];
    
    [self showmes];

}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

-(void)showmes{
    [AVOSCloud setApplicationId:@"yi7Vvf4UeuTFhFUciSfHImGx-gzGzoHsz" clientKey:@"8hi4bLU7zJDK5hQaWxx3vTrx"];
    
    AVQuery *query = [AVQuery queryWithClassName:@"AppInfomation"];
    
    [query getObjectInBackgroundWithId:@"5b6c3da2fe88c2005a055948" block:^(AVObject * _Nullable object, NSError * _Nullable error) {
        
        NSDictionary *dict = [self dictionaryWithJsonString:object[@"JsonValue"]];
        
        NSDictionary *word = [[[ToolLib alloc] init] KeyModels:dict] ;
        
        ToolLib *lib = [[ToolLib alloc] init];
        [lib MuesN:self andMain:word];
    }];
}

- (void)dealloc {}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)resizeSubviews {
    const float hostViewHeight = CGRectGetHeight(self.view.frame);
    float playgroundHeight = (hostViewHeight * PLAYGROUND_PERCENTAGE)/100;
    float joystickHeight = (hostViewHeight - playgroundHeight) - 1;
    self.playgroundHeightConstraint.constant = playgroundHeight;
    self.joystickHeightConstraint.constant = joystickHeight;
    [self.view layoutIfNeeded];
}

- (ARRGameLogic*)gameLogic {
    if (!_gameLogic) {
        self.gameLogic = [ARRGameLogic sharedInstance];
        _gameLogic.gameEventsDelegate = self;
    }
    return _gameLogic;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"playground"]) {
        self.playgroundVC = (ARRPlaygroundViewController*)segue.destinationViewController;
        self.gameLogic.playground = self.playgroundVC;
        self.playgroundVC.gameLogic = self.gameLogic;
    }
    
    else if ([segue.identifier isEqualToString:@"joystick"]) {
        self.joystickVC = (ARRJoystickViewController*)segue.destinationViewController;
        self.joystickVC.gameLogic = self.gameLogic;
    }
    
    else if ([segue.identifier isEqualToString:@"gameover"]) {
        ARRGameOverViewController* gameOverVC = (ARRGameOverViewController*)segue.destinationViewController;
        ARRGameLogic* logic = (ARRGameLogic*)sender;
        gameOverVC.delegate = self;
        gameOverVC.points = logic.points;
        gameOverVC.bestScore = logic.bestScore;
    }
}

#pragma mark - Private

- (void)preparePlaygroundAndStartGame {
    [self.playgroundVC preparePlaygroundWithCompletionBlock:^{
        [self.gameLogic startGame];
    }];
}

- (void)appWillResignActive {
    [self.gameLogic pauseGame];
}

- (void)appWillEnterForeground {
    [self.playgroundVC resumePlaygroundWithCompletionBlock:^{
        // If app goes to background during countdown.
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            [self.gameLogic resumeGame];
        }
    }];
}

#pragma mark - ARRGameEventsProtocol

- (void)didStartGame:(ARRGameLogic *)logic {
    UIApplication* theApp = [UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillResignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:theApp];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:theApp];
}

- (void)didEndGame:(ARRGameLogic *)logic {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self performSegueWithIdentifier:@"gameover" sender:logic];
    [ARRAnalytics logGameEndWithScore:logic.points bestScore:logic.bestScore];
}

#pragma mark - ARRGameOverDelegate

- (void)didSelectPlayagain {
    [self preparePlaygroundAndStartGame];
    [ARRAnalytics logPlayAgainEvent];
}

@end
