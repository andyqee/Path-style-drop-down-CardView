//
//  YQLoginCardView.h
//  YQDropdownCardView
//
//  Created by andy on 6/8/14.
//  Copyright (c) 2014 andy. All rights reserved.
//

#import "YQCardBaseView.h"

@protocol YQLoginCardViewDelegate;

@interface YQLoginCardView : YQCardBaseView

@property (nonatomic, weak) id<YQLoginCardViewDelegate> delegate;
@property (nonatomic, copy) dispatch_block_t leftButtonActionBlock;
@property (nonatomic, copy) dispatch_block_t rightButtonActionBlock;
- (void)showView;
- (void)dismissView;
@end

@protocol YQLoginCardViewDelegate <NSObject>
@optional
- (void)didClickTopButton;

@end
