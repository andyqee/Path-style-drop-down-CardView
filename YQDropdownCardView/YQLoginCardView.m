//
//  YQLoginCardView.m
//  YQDropdownCardView
//
//  Created by andy on 6/8/14.
//  Copyright (c) 2014 andy. All rights reserved.
//

#import "YQLoginCardView.h"

static const float kCardViewXoffSet = 30.0;
static const float kCardViewYoffSet = 140.0;
static const float kCardViewWith = 260.0;
static const float kCardViewHeight = 245.0;

@implementation YQLoginCardView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

#pragma mark - public method
- (void)showView
{
    UIViewController *topViewController = [self appRootViewController];
    self.frame = CGRectMake(kCardViewXoffSet,-kCardViewHeight - 30, kCardViewWith, kCardViewHeight);
    [topViewController.view addSubview:self];
}

- (void)dismissView
{
    [self removeFromSuperview];
}

- (void)removeFromSuperview
{
    CGFloat xOffSet = ([[UIScreen mainScreen] bounds].size.width - kCardViewWith) / 2;
    CGFloat yOffSet = [[UIScreen mainScreen] bounds].size.height;
    CGRect afterFrame = CGRectMake(xOffSet, yOffSet, kCardViewWith, kCardViewHeight);
    [UIView animateWithDuration:0.25f delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.frame = afterFrame;
        self.backImageView.alpha = 0;
    } completion:^(BOOL finished) {
        self.isOnScreen = NO;
        [super removeFromSuperview];
        [self.backImageView removeFromSuperview];
        self.backImageView = nil;
    }];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview == nil) {
        return;
    }
    UIWindow *shareWindow = [UIApplication sharedApplication].keyWindow;
    UIViewController *topViewController = [self appRootViewController];
    if (!self.backImageView) {
        self.backImageView = [[UIView alloc] initWithFrame:shareWindow.bounds];
        self.backImageView.backgroundColor = [UIColor blackColor];
        self.backImageView.alpha = 0.01f;
        UIControl *backImageViewControl = [[UIControl alloc] initWithFrame:shareWindow.bounds];
        backImageViewControl.alpha = 0.1f;
        backImageViewControl.userInteractionEnabled = YES;
        [backImageViewControl addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];
        [self.backImageView addSubview:backImageViewControl];
    }
    [topViewController.view addSubview:self.backImageView];
    self.transform = CGAffineTransformMakeRotation(-M_1_PI / 2);
    CGRect afterFrame = CGRectMake(kCardViewXoffSet, kCardViewYoffSet, kCardViewWith, kCardViewHeight);
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        [UIView animateWithDuration:0.6f delay:0.0f usingSpringWithDamping:0.6 initialSpringVelocity:0.4 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.backImageView.alpha = 0.5f;
            self.transform = CGAffineTransformMakeRotation(0);
            self.frame = afterFrame;
        } completion:^(BOOL finished) {
            self.isOnScreen = YES;
        }];
    } else {
        [UIView animateWithDuration:0.40f delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.backImageView.alpha = 0.5f;
            self.transform = CGAffineTransformMakeRotation(0);
            self.frame = afterFrame;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.06f delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.frame = CGRectMake(kCardViewXoffSet - 1, kCardViewYoffSet - 7, kCardViewWith, kCardViewHeight);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.06f delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    self.frame = CGRectMake(kCardViewXoffSet, kCardViewYoffSet, kCardViewWith, kCardViewHeight);
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.02f delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                        self.frame = CGRectMake(kCardViewXoffSet, kCardViewYoffSet - 2, kCardViewWith, kCardViewHeight);
                    } completion:^(BOOL finished) {
                        [UIView animateWithDuration:0.02f delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                            self.frame = CGRectMake(kCardViewXoffSet, kCardViewYoffSet, kCardViewWith, kCardViewHeight);
                        } completion:^(BOOL finished) {
                            self.isOnScreen = YES;
                        }];
                    }];
                }];
            }];
        }];
    }
    [super willMoveToSuperview:newSuperview];
}

- (UIViewController *)appRootViewController
{
    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topViewController = appRootVC;
    while (topViewController.presentedViewController) {
        topViewController = topViewController.presentedViewController;
    }
    return topViewController;
}

@end
