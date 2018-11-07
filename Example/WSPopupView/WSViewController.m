//
//  WSViewController.m
//  WSPopupView
//
//  Created by 351473007@qq.com on 11/07/2018.
//  Copyright (c) 2018 351473007@qq.com. All rights reserved.
//

#import "WSViewController.h"
#import <WSPopupView/WSPopupView.h>
@interface WSViewController ()

@end

@implementation WSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 400)];
    view.backgroundColor = [UIColor clearColor];
    
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    view1.backgroundColor = [UIColor redColor];
    [view addSubview:view1];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(70, 300, 60, 60);
    [button setBackgroundColor:[UIColor redColor]];
    [button addTarget:self action:@selector(aaa) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    
    WSPopupView *popView = [WSPopupView popupViewWithContentView:view showType:WSPopupShowTypeSlideFromTop hiddenType:WSPopupHiddenTypeSlideToTop];
    popView.backgroundAlpfa = 0.4;
    popView.duration = 10;
    popView.hiddenOnBackgroundTouch = YES;
    [popView showInView:self.view animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
