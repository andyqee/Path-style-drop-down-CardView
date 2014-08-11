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

@interface YQCardBaseView()
@property (nonatomic) CGPoint initialLocation;
@property (nonatomic) CGRect originalFrame;
@property (nonatomic) CGRect originalBounds;
@property (nonatomic) CGFloat originalPositionX;
@property (nonatomic) CGFloat originalPositionY;
@property (nonatomic) CGFloat originalBkViewAlpha;
@property (nonatomic) BOOL firstGestureAction;

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
            self.originalBkViewAlpha = self.backImageView.alpha;
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
            self.backImageView.alpha = self.originalBkViewAlpha * (1 - distanceOffsetRatio);
        }
        recognizer.view.transform = CGAffineTransformMakeRotation(angle);
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
    __weak typeof(self) blockSelf = self;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        [UIView animateWithDuration:0.6 delay:0.0f usingSpringWithDamping:0.6f initialSpringVelocity:0 options:UIViewAnimationOptionCurveLinear animations:^{
            blockSelf.transform = CGAffineTransformIdentity;
            blockSelf.frame = blockSelf.originalFrame;
            blockSelf.backImageView.alpha = blockSelf.originalBkViewAlpha;
        } completion:^(BOOL finished){
            self.autoresizingMask = NO;
        }];
    } else {
        [UIView animateWithDuration:0.6 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            blockSelf.transform = CGAffineTransformIdentity;
            blockSelf.frame = blockSelf.originalFrame;
            blockSelf.backImageView.alpha = blockSelf.originalBkViewAlpha;
        } completion:^(BOOL finished){
            self.autoresizingMask = NO;
        }];
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