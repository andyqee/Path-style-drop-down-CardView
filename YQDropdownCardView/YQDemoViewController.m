//
//  YQDemoViewController.m
//  YQDropdownCardView
//
//  Created by andy on 6/8/14.
//  Copyright (c) 2014 andy. All rights reserved.
//

#import "YQDemoViewController.h"
#import "YQLoginCardView.h"

@interface YQDemoViewController ()
@property (nonatomic, strong) UIButton *showButton;

@end

@implementation YQDemoViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIButton *showButton = [UIButton buttonWithType:UIButtonTypeCustom];
    showButton.frame = CGRectMake(60, 200, 200, 50);
    showButton.center = self.view.center;
    [showButton setTitle:@"show card view" forState:UIControlStateNormal];
    showButton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    showButton.titleLabel.textColor = [UIColor brownColor];
    [showButton addTarget:self action:@selector(showAction) forControlEvents:UIControlEventTouchUpInside];
    self.showButton = showButton;
    [self.view addSubview:self.showButton];
    self.title = @"animation card view";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark button action
- (void)showAction
{
    YQLoginCardView *loginCardView = [[YQLoginCardView alloc] init];
    [loginCardView showView];
}
@end
