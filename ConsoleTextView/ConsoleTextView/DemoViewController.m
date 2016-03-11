//
//  DemoViewController.m
//  ConsoleTextView
//
//  Created by 张小刚 on 16/3/9.
//  Copyright © 2016年 lyeah company. All rights reserved.
//

#import "DemoViewController.h"
#import "ConsoleTextView.h"

@interface DemoViewController ()

@property (weak, nonatomic) IBOutlet ConsoleTextView *textView;
@property (nonatomic, strong) NSTimer * timer;

@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textView.scrollDirection = CTVScrollDirectionDown;
    [self startLoggerTest];
}

- (void)startLoggerTest
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(logSomething) userInfo:nil repeats:YES];
}

- (void)logSomething
{
    NSString * randomText = [NSString stringWithFormat:@"random text %@",[NSDate date]];
    [self.textView log:randomText];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.timer invalidate];
    self.timer = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    NSLog(@"dealloced ");
}


@end
