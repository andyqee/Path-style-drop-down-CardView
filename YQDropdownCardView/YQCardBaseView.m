//
//  YQCardBaseView.m
//  YQDropdownCardView
//
//  Created by Yi Qi on 6/8/14.
//  Email: vitasone@gmail.com
//  Copyright (c) 2014 andy. All rights reserved.
//

#import "YQCardBaseView.h"

static CGFloat velocityThreshold = 1800.0f;
static CGFloat removeAnimationDurationThreshold = 0.3f;
static CGFloat maxRotationAngle = M_PI / 18.0f;

static const float kCardViewXoffSet = 30.0;
static const float kCardViewYoffSet = 140.0;
static const float kCardViewWith = 260.0;
static const float kCardViewHeight = 245.0;

@interface YQCardBaseView()
@property (nonatomic) CGPoint initialLocation;
@property (nonatomic) CGRect originalFrame;
@property (nonatomic) CGRect originalBounds;
@property (nonatomic) CGFloat originalPositionX;
@property (nonatomic) CGFloat originalPositionY;
@property (nonatomic) BOOL firstGestureAction;
@property (nonatomic) CGFloat totalAngle;

@property (nonatomic, strong) UIView *backImageView;

@end

@implementation YQCardBaseView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _firstGestureAction = YES;
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [self addGestureRecognizer:panRecognizer];
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

- (UIViewController *)appRootViewController
{
    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topViewController = appRootVC;
    while (topViewController.presentedViewController) {
        topViewController = topViewController.presentedViewController;
    }
    return topViewController;
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

- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self];
    CGFloat angle;
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (self.firstGestureAction) {
            self.originalFrame = recognizer.view.frame;
            self.originalBounds = recognizer.view.bounds;
            self.originalPositionX = CGRectGetMidX(self.originalFrame);
            self.originalPositionY = CGRectGetMidY(self.originalFrame);
            self.firstGestureAction = NO;
        }
        self.initialLocation = location;
    }
    CGPoint translation = [recognizer translationInView:self.superview];
    CGFloat velocityY = [recognizer velocityInView:self].y;
    if (velocityY < 0 && recognizer.view.center.y < self.originalPositionY) {
        CGFloat offSetY = 1 * log10f(fabsf(translation.y) + 1);
        CGFloat y = recognizer.view.center.y - offSetY;
        recognizer.view.center = CGPointMake(recognizer.view.center.x, y);
    } else {
        recognizer.view.center = CGPointMake(recognizer.view.center.x, recognizer.view.center.y + translation.y);
        if (location.y == self.originalPositionY) {
            angle = 0.0f;
        } else {
            CGFloat positionRatio = (location.x - self.originalPositionX) / CGRectGetWidth(self.originalFrame);
            CGFloat distanceOffsetRatio = (recognizer.view.center.y - self.originalPositionY) / (CGRectGetHeight(self.superview.frame) - self.originalPositionY);
            angle = positionRatio * distanceOffsetRatio * maxRotationAngle;
        }
        recognizer.view.transform = CGAffineTransformMakeRotation(angle);
        self.totalAngle = angle;
    }
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.superview];
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint currentLocation = recognizer.view.center;
        if (recognizer.view.center.y > self.originalPositionY) {
            if (velocityY >= velocityThreshold) {
                [self removeOutOfScreenFromCurrentLocation:currentLocation WithVelocity:velocityY];
            } else {
                if (recognizer.view.center.y > self.superview.layer.frame.size.height) {
                    [self removeOutOfScreenFromCurrentLocation:currentLocation WithVelocity:velocityY];
                } else {
                    [self moveBackToOriginalLoacationWithVelocity:velocityY];
                }
            }
        } else {
            [self stickToOriginalPositionFromCurrentLocation:currentLocation];
        }
    }
}

- (void)touchDown:(UIControl *)sender
{
    
}

- (void)touchUpInside:(UIControl *)sender
{
    
}

#pragma mark - animation method

- (void)removeOutOfScreenFromCurrentLocation:(CGPoint)location WithVelocity:(CGFloat)velocity
{
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"position.y";
    CGFloat fromValue = location.y;
    animation.fromValue = @(fromValue);
    
    CGFloat toValue = CGRectGetHeight(self.frame) / 2 + CGRectGetHeight(self.superview.frame);
    CGFloat duration = (toValue - self.center.y) / velocity;
    duration = MIN(duration, removeAnimationDurationThreshold);
    animation.duration = duration;
    animation.toValue = @(toValue);
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    [self.layer addAnimation:animation forKey:@"remove"];
    self.isOnScreen = NO;
    self.layer.position = CGPointMake(location.x, toValue);
}

- (void)moveBackToOriginalLoacationWithVelocity:(CGFloat)velocity
{
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        __weak typeof(self) blockSelf = self;
        [UIView animateWithDuration:0.6 delay:0.0f usingSpringWithDamping:0.6f initialSpringVelocity:0 options:UIViewAnimationOptionCurveLinear animations:^{
            blockSelf.transform = CGAffineTransformIdentity;
            blockSelf.frame = blockSelf.originalFrame;
        } completion:^(BOOL finished){
            self.totalAngle = 0;
            self.autoresizingMask = NO;
        }];
    } else {
        
    }
}

- (void)stickToOriginalPositionFromCurrentLocation:(CGPoint)location
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    CGPoint toValue = CGPointMake(self.originalPositionX, self.originalPositionY);
    animation.fromValue = [NSValue valueWithCGPoint:location];
    animation.toValue = [NSValue valueWithCGPoint:toValue];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.duration = 0.2f;
    
    [self.layer addAnimation:animation forKey:@"stickToOrigin"];
    self.layer.position = toValue;
}

#pragma mark multiply vector
- (CGFloat)multiplyVector:(CGPoint)vectorA withVector:(CGPoint)vectorB
{
    CGFloat result;
    result = vectorA.x * vectorB.x - vectorA.y * vectorB.y;
    return result;
}

#pragma mark
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    
}

@end