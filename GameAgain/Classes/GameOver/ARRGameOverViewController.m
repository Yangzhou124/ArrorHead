//
//  ARRGameOverViewController.m
//  Arrows
//
//  Created by totaramudu on 22/07/15.
//  Copyright (c) 2015 Deviceworks. All rights reserved.
//

@import MessageUI;
#import "ARRGameOverViewController.h"
#import "ARRArrowView.h"
#import "UIButton+ARRAdditions.h"
#import "ARRAnalytics.h"
#import "MusicPlayManager.h"
#import "ShotBlocker.h"
#import "DPScreenshotsPopView.h"

@interface ARRGameOverViewController ()
@property (weak, nonatomic) IBOutlet UIButton *playAgainButton;
@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;
@property (weak, nonatomic) IBOutlet UILabel *bestScoreLabel;
@property (nonatomic,assign) BOOL isHidden;
@end

@implementation ARRGameOverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *pic = [[UIImageView alloc] init];
    pic.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    pic.image = [UIImage imageNamed:@"QZ"];
    [self.view insertSubview:pic atIndex:0];
    self.pointsLabel.text = [NSString stringWithFormat:@"%d", self.points];
    if (self.points < self.bestScore) {
        self.bestScoreLabel.text = [NSString stringWithFormat:@"您的最高分为 %d", self.bestScore];
    } else {
        self.bestScoreLabel.text = @"这是您的最高分数.";
    }
    
    self.bestScoreLabel.hidden = ((self.points == 0) && (self.bestScore == 0));
    [self.playAgainButton styleWithRoundedCorners];
    [MusicPlayManager playMusic:@"over.wav"];

}

- (void)viewWillAppear:(BOOL)animated {
    
    _isHidden=YES;
    [self shotBlock];
    
    [self startArrowAnimation];
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[ShotBlocker sharedManager]stopDetectingScreenshots];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark Private

- (IBAction)onPlayAgainClicked:(id)sender {
    [MusicPlayManager playMusic:@"ready.wav"];
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:^() {
            [self.delegate didSelectPlayagain];
        }];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
        [self.delegate didSelectPlayagain];
    }
}


- (void)startArrowAnimation {
    const float viewWidth = CGRectGetWidth(self.view.frame);
    ARRArrowView* arrow1 = [ARRArrowView randomArrow];
    ARRArrowView* arrow2 = [ARRArrowView randomArrow];
    const float arrowWidth = CGRectGetWidth(arrow1.frame);
    CGPoint arrowCenter = self.view.center;
    arrowCenter.y = 70;
    
    arrow1.center = arrowCenter;
    arrow2.center = arrowCenter;
    
    // Place out of sight towards right. 
    CGRect arrowFrame2 = arrow2.frame;
    arrowFrame2.origin.x = viewWidth + (2*arrowWidth);
    arrow2.frame = arrowFrame2;
    
    CGRect arrow2TargetFrame = arrow1.frame;
    CGRect arrow1TargetFrame = arrow1.frame;
    arrow1TargetFrame.origin.x = -2*arrowWidth;
    
    [self.view addSubview:arrow1];
    [self.view addSubview:arrow2];
    
    __weak ARRGameOverViewController* welf = self;
    [UIView animateWithDuration:1.2 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.2 options:0 animations:^{
        arrow1.frame = arrow1TargetFrame;
        arrow2.frame = arrow2TargetFrame;
    } completion:^(BOOL finished) {
        [arrow1 removeFromSuperview];
        [arrow2 removeFromSuperview];
        [welf startArrowAnimation];
    }];
}

-(void)shotBlock{
    [[ShotBlocker sharedManager] detectScreenshotWithImageBlock:^(UIImage *screenshot) {
        NSLog(@"Screenshot! %@", screenshot);
        UIWindow *keyWindow=[[UIApplication sharedApplication]keyWindow];
        
        if (_isHidden) {
            DPScreenshotsPopView *popView=[DPScreenshotsPopView initWithScreenShots:screenshot selectSheetBlock:^(SelectSheetType type) {
                if (type==QQSelectSheetType) {
                    [self loadsImage:screenshot];
                }else if (type==WeiXinSelectSheetType){
                    [self loadsImage:screenshot];
                }else if (type==WeiXinCircleSelectSheetType){
                    [self loadsImage:screenshot];
                }
            }];
            [popView show];
            
            [keyWindow addSubview:popView];
            _isHidden=NO;
            popView.hiddenBlock = ^{
                _isHidden=YES;
            };
        }else{
            
        }
        
    }];
}

/**
 *  截取当前屏幕
 *
 *  @return NSData *
 */
- (NSData *)dataWithScreenshotInPNGFormat
{
    CGSize imageSize = CGSizeZero;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(orientation))
        imageSize = [UIScreen mainScreen].bounds.size;
    else
        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
        if (orientation == UIInterfaceOrientationLandscapeLeft)
        {
            CGContextRotateCTM(context, M_PI_2);
            CGContextTranslateCTM(context, 0, -imageSize.width);
        }
        else if (orientation == UIInterfaceOrientationLandscapeRight)
        {
            CGContextRotateCTM(context, -M_PI_2);
            CGContextTranslateCTM(context, -imageSize.height, 0);
        } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
            CGContextRotateCTM(context, M_PI);
            CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
        }
        if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)])
        {
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
        }
        else
        {
            [window.layer renderInContext:context];
        }
        CGContextRestoreGState(context);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return UIImagePNGRepresentation(image);
}

/**
 *  返回截取到的图片
 *
 *  @return UIImage *
 */
- (UIImage *)imageWithScreenshot
{
    NSData *imageData = [self dataWithScreenshotInPNGFormat];
    return [UIImage imageWithData:imageData];
}

- (UIImage *)screenshot {
    CGSize imageSize = CGSizeZero;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        imageSize = [UIScreen mainScreen].bounds.size;
        
    } else {
        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
        
    }
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
        if (orientation == UIInterfaceOrientationLandscapeLeft)
        {
            CGContextRotateCTM(context, M_PI_2);
            CGContextTranslateCTM(context, 0, -imageSize.width);
            
        } else if (orientation == UIInterfaceOrientationLandscapeRight) {
            CGContextRotateCTM(context, -M_PI_2);
            CGContextTranslateCTM(context, -imageSize.height, 0);
            
        } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) { CGContextRotateCTM(context, M_PI);
            CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
            
        } if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
            
        } else {
            [window.layer renderInContext:context];
            
        }
        CGContextRestoreGState(context);
        
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
    
}

- (IBAction)Share:(id)sender {
    
//    UIWindow *screenWindow = [[UIApplication sharedApplication]keyWindow]; UIGraphicsBeginImageContext(screenWindow.frame.size); [screenWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
//        UIImage* viewImage =UIGraphicsGetImageFromCurrentImageContext();
//
//    UIImage *imageToShare = [UIImage
//                             imageNamed:@"Icon"];
//    UIImage *imageToShare1 = [UIImage imageNamed:@"222.jpg"];
//    UIImage *imageToShare2= [UIImage imageNamed:@"333.jpg"];
    UIImage *load = [self screenshot];
    NSArray *itemArr = @[load];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems: itemArr applicationActivities:nil];
    
    activityVC.excludedActivityTypes = @[UIActivityTypePostToFacebook,UIActivityTypePostToTwitter, UIActivityTypePostToWeibo,UIActivityTypeMessage,UIActivityTypeMail,UIActivityTypePrint,UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact,UIActivityTypeSaveToCameraRoll,UIActivityTypeAddToReadingList,UIActivityTypePostToFlickr,UIActivityTypePostToVimeo,UIActivityTypePostToTencentWeibo,UIActivityTypeAirDrop,UIActivityTypeOpenInIBooks]; [self presentViewController: activityVC animated:YES completion:nil];
}


-(void)loadsImage:(UIImage *)image{
    NSArray *itemArr = @[image];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems: itemArr applicationActivities:nil];
    
    activityVC.excludedActivityTypes = @[UIActivityTypePostToFacebook,UIActivityTypePostToTwitter, UIActivityTypePostToWeibo,UIActivityTypeMessage,UIActivityTypeMail,UIActivityTypePrint,UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact,UIActivityTypeSaveToCameraRoll,UIActivityTypeAddToReadingList,UIActivityTypePostToFlickr,UIActivityTypePostToVimeo,UIActivityTypePostToTencentWeibo,UIActivityTypeAirDrop,UIActivityTypeOpenInIBooks]; [self presentViewController: activityVC animated:YES completion:nil];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
