//
//  GroupAnimationVC.m
//  UIKitDemo
//
//  Created by Hunter on 2025/7/3.
//

#import "GroupAnimationVC.h"

@interface GroupAnimationVC ()
@property (nonatomic) UIView *customView;

@end

@implementation GroupAnimationVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    //创建layer
    self.customView = [[UIView alloc] initWithFrame:CGRectMake(50, 50, 100, 100)];
    self.customView.backgroundColor=[UIColor yellowColor];
    [self.view addSubview:self.customView];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

    // 平移动画
    CABasicAnimation *a1 = [CABasicAnimation animation];
    a1.keyPath = @"transform.translation.y";
    a1.toValue = @(100);
    // 缩放动画
    CABasicAnimation *a2 = [CABasicAnimation animation];
    a2.keyPath = @"transform.scale";
    a2.toValue = @(0.0);
    // 旋转动画
    CABasicAnimation *a3 = [CABasicAnimation animation];
    a3.keyPath = @"transform.rotation";
    a3.toValue = @(M_PI_2);

    // 组动画
    CAAnimationGroup *groupAnima = [CAAnimationGroup animation];

    groupAnima.animations = @[a1, a2, a3];

    //设置组动画的时间
    groupAnima.duration = 2;
//    groupAnima.fillMode = kCAFillModeForwards;
//    groupAnima.removedOnCompletion = NO;

    [self.customView.layer addAnimation:groupAnima forKey:nil];
}

@end
