//
//  KeyFrameAnimationVC.m
//  UIKitDemo
//
//  Created by Hunter on 2025/7/3.
//

#import "KeyFrameAnimationVC.h"
#import <objc/runtime.h>
#import <objc/message.h>

#define angle2Radian(angle)  ((angle)/180.0*M_PI)

@interface KeyFrameAnimationVC ()
@property (nonatomic) UIView *customView;
@end

@implementation KeyFrameAnimationVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    //创建layer
    self.customView = [[UIView alloc] initWithFrame:CGRectMake(50, 50, 100, 100)];
//    [self.customView setBounds:CGRectMake(100, 100, 20, 20)];
    self.customView.backgroundColor=[UIColor yellowColor];
    [self.view addSubview:self.customView];


    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(100, 200, 100, 50);
    btn.backgroundColor=[UIColor redColor];
    [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

//
//+ (BOOL)resolveInstanceMethod:(SEL)sel {
//    return  YES;
//}
//
//- (id)forwardingTargetForSelector:(SEL)aSelector {
//    return  nil;
//}
//
//- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
//    return nil;
//}
//
//- (void)forwardInvocation:(NSInvocation *)anInvocation {
//
//}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //1.创建核心动画
    CAKeyframeAnimation *keyAnima=[CAKeyframeAnimation animation];
    //平移
    keyAnima.keyPath=@"position";
    //1.1告诉系统要执行什么动画
    NSValue *value1=[NSValue valueWithCGPoint:CGPointMake(100, 100)];
    NSValue *value2=[NSValue valueWithCGPoint:CGPointMake(200, 100)];
    NSValue *value3=[NSValue valueWithCGPoint:CGPointMake(200, 200)];
    NSValue *value4=[NSValue valueWithCGPoint:CGPointMake(100, 200)];
    NSValue *value5=[NSValue valueWithCGPoint:CGPointMake(100, 100)];
    keyAnima.values=@[value1,value2,value3,value4,value5];
    //1.2设置动画执行完毕后，不删除动画
    keyAnima.removedOnCompletion=NO;
    //1.3设置保存动画的最新状态
    keyAnima.fillMode=kCAFillModeForwards;
    //1.4设置动画执行的时间
    keyAnima.duration=4.0;
    //1.5设置动画的节奏
    keyAnima.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

    //设置代理，开始—结束
    keyAnima.delegate=(id)self;
    //2.添加核心动画
    [self.customView.layer addAnimation:keyAnima forKey:nil];
}

// 抖动动画
- (void)btnAction:(UIButton *)btn {
    //1.创建核心动画
    CAKeyframeAnimation *keyAnima=[CAKeyframeAnimation animation];
    keyAnima.keyPath=@"transform.rotation";
    //设置动画时间
    keyAnima.duration=0.1;
    //设置图标抖动弧度
    //把度数转换为弧度  度数/180*M_PI
    keyAnima.values=@[@(-angle2Radian(4)),@(angle2Radian(4)),@(-angle2Radian(4))];
    //设置动画的重复次数
    keyAnima.repeatCount=20;

//    keyAnima.fillMode=kCAFillModeForwards;
//    keyAnima.removedOnCompletion=NO;
    //2.添加动画
    [self.customView.layer addAnimation:keyAnima forKey:nil];
}

-(void)animationDidStart:(CAAnimation *)anim
{
    NSLog(@"开始动画");
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSLog(@"结束动画");
}
@end
