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
    showButton.backgroundColor = [UIColor yellowColor];
    [showButton setTitle:@"show card view" forState:UIControlStateNormal];
    [showButton setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
    showButton.titleLabel.font = [UIFont systemFontOfSize:20.0f];
    [showButton addTarget:self action:@selector(showAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:showButton];
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
