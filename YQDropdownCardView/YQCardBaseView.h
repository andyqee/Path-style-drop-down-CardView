//
//  YQCardBaseView.h
//  YQDropdownCardView
//
//  Created by Yi Qi on 6/8/14.
//  Copyright (c) 2014 andy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YQCardBaseView : UIControl
@property (nonatomic) BOOL isOnScreen;
- (void)showView;
- (void)dismissView;

@end
