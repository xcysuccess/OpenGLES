//
//  ViewController.m
//  OpenGLESFirstApp
//
//  Created by tomxiang on 2017/9/5.
//  Copyright © 2017年 tomxiang. All rights reserved.
//

#import "ViewController.h"
#import "XXOpenGLView.h"

@interface ViewController ()
@property(nonatomic,strong) XXOpenGLView *openGLView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    // Do any additional setup after loading the view, typically from a nib.
    self.openGLView = [[XXOpenGLView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_openGLView];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
