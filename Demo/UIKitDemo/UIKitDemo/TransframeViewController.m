//
//  TransframeViewController.m
//  练习使用按钮的frame和center属性
//  https://www.cnblogs.com/wendingding/p/3742092.html
//  Created by Hunter on 2025/7/3.
//

#import "TransframeViewController.h"
#import "CABaseAnimationViewController.h"
#import "KeyFrameAnimationVC.h"
#import "TransitionAnimationVC.h"
#import "GroupAnimationVC.h"


//私有扩展
@interface TransframeViewController ()

@property(nonatomic, strong) UIButton *headImageView;

@end

@implementation TransframeViewController

//枚举类型，从1开始
//枚举类型有一个很大的作用，就是用来代替程序中的魔法数字
typedef enum
{
    ktopbtntag=1,
    kdownbtntag,
    kleftbtntag,
    krightbtntag
}btntag;

//viewDidLoad是视图加载完成后调用的方法，通常在此方法中执行视图控制器的初始化工作
- (void)viewDidLoad
{

    //在viewDidLoad方法中，不要忘记调用父类的方法实现
    [super viewDidLoad];


    //手写控件代码
    //一、写一个按钮控件，上面有一张图片

    //1.使用类创建一个按钮对象
    // UIButton *headbtn=[[UIButton alloc] initWithFrame:CGRectMake(100 ,100, 100, 100)];
    //设置按钮对象为自定义型
    UIButton *headbtn=[UIButton buttonWithType:UIButtonTypeCustom];

    //2.设置对象的各项属性

    //(1)位置等通用属性设置
    headbtn.frame=CGRectMake(100, 100, 100, 100);

    //(2)设置普通状态下按钮的属性
    [headbtn setBackgroundImage:[UIImage systemImageNamed:@"car.circle"] forState:UIControlStateNormal];
    [headbtn setTitle:@"点我！" forState:UIControlStateNormal];
    [headbtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];

    //(3)设置高亮状态下按钮的属性
    [headbtn setBackgroundImage:[UIImage systemImageNamed:@"car.circle.fill"] forState:UIControlStateHighlighted];
    [headbtn setTitle:@"还行吧~" forState:UIControlStateHighlighted];
    [headbtn setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];

    //3.把对象添加到视图中展现出来
    [self.view addSubview:headbtn];
    //注意点！
    self.headImageView=headbtn;


    //二、写四个控制图片左右上下移动方向的按钮控件

    /**================向上的按钮=====================*/
    //1.创建按钮对象
    UIButton *topbtn=[UIButton buttonWithType:UIButtonTypeCustom];

    //2.设置对象的属性
    topbtn.frame=CGRectMake(100, 250, 40, 40);
    [topbtn setBackgroundImage:[UIImage systemImageNamed:@"arrow.up"] forState:UIControlStateNormal];
    [topbtn setBackgroundImage:[UIImage systemImageNamed:@"arrow.up.circle"] forState:UIControlStateHighlighted];
    [topbtn setTag:1];
    //3.把控件添加到视图中
    [self.view addSubview:topbtn];

    //4.按钮的单击控制事件
    [topbtn addTarget:self action:@selector(Click:) forControlEvents:UIControlEventTouchUpInside];


    /**================向下的按钮=====================*/
    //1.创建按钮对象
    UIButton *downbtn=[UIButton buttonWithType:UIButtonTypeCustom];
    //2.设置对象的属性
    downbtn.frame=CGRectMake(100, 350, 40, 40);
    [downbtn setBackgroundImage:[UIImage systemImageNamed:@"arrow.down"] forState:UIControlStateNormal];
    [downbtn setBackgroundImage:[UIImage systemImageNamed:@"arrow.down.circle"] forState:UIControlStateHighlighted];
    [downbtn setTag:2];
    //3.把控件添加到视图中
    [self.view addSubview:downbtn];

    //4.按钮的单击控制事件
    [downbtn addTarget:self action:@selector(Click:) forControlEvents:UIControlEventTouchUpInside];


    /**================向左的按钮=====================*/
    //1.创建按钮对象
    UIButton *leftbtn=[UIButton buttonWithType:UIButtonTypeCustom];
    //2.设置对象的属性
    leftbtn.frame=CGRectMake(50, 300, 40, 40);
    [leftbtn setBackgroundImage:[UIImage systemImageNamed:@"arrow.left"] forState:UIControlStateNormal];
    [leftbtn setBackgroundImage:[UIImage systemImageNamed:@"arrow.left.circle"] forState:UIControlStateHighlighted];
    [leftbtn setTag:3];
    //3.把控件添加到视图中
    [self.view addSubview:leftbtn];

    //4.按钮的单击控制事件
    [leftbtn addTarget:self action:@selector(Click:) forControlEvents:UIControlEventTouchUpInside];



    /**================向右的按钮=====================*/
    //1.创建按钮对象
    UIButton *rightbtn=[UIButton buttonWithType:UIButtonTypeCustom];
    //2.设置对象的属性
    rightbtn.frame=CGRectMake(150, 300, 40, 40);
    [rightbtn setBackgroundImage:[UIImage systemImageNamed:@"arrow.right"] forState:UIControlStateNormal];
    [rightbtn setBackgroundImage:[UIImage systemImageNamed:@"arrow.right.circle"] forState:UIControlStateHighlighted];
    [rightbtn setTag:4];
    //3.把控件添加到视图中
    [self.view addSubview:rightbtn];

    //4.按钮的单击控制事件
    [rightbtn addTarget:self action:@selector(Click:) forControlEvents:UIControlEventTouchUpInside];

    //三、写两个缩放按钮
    /**================放大的按钮=====================*/
    //1.创建对象
    UIButton *plusbtn=[UIButton buttonWithType:UIButtonTypeCustom];
    //2.设置属性
    plusbtn.frame=CGRectMake(75, 400, 40, 40);
    [plusbtn setBackgroundImage:[UIImage systemImageNamed:@"calendar.badge.plus"] forState:UIControlStateNormal];
    [plusbtn setBackgroundImage:[UIImage systemImageNamed:@"calendar.badge.clock.rtl"] forState:UIControlStateHighlighted];
    [plusbtn setTag:1];
    //3.添加到视图
    [self.view addSubview:plusbtn];
    //4.单击事件
    [plusbtn addTarget:self action:@selector(Zoom:) forControlEvents:UIControlEventTouchUpInside];


    /**================缩小的按钮=====================*/
    UIButton *minusbtn=[UIButton buttonWithType:UIButtonTypeCustom];
    minusbtn.frame=CGRectMake(125, 400, 40, 40);
    [minusbtn setBackgroundImage:[UIImage systemImageNamed:@"calendar.badge.minus"] forState:UIControlStateNormal];
    [minusbtn setBackgroundImage:[UIImage systemImageNamed:@"calendar.badge.clock.rtl"] forState:UIControlStateHighlighted];
    [minusbtn setTag:0];
    [self.view addSubview:minusbtn];
    [minusbtn addTarget:self action:@selector(Zoom:) forControlEvents:UIControlEventTouchUpInside];

    /**================向左旋转按钮=====================*/
    UIButton *leftrotatebtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [leftrotatebtn setFrame:CGRectMake(175, 400, 40, 40)];
    [leftrotatebtn setBackgroundImage:[UIImage systemImageNamed:@"rotate.left"] forState:UIControlStateNormal];
    [leftrotatebtn setBackgroundImage:[UIImage systemImageNamed:@"rotate.left.fill"] forState:UIControlStateHighlighted];
    [leftrotatebtn setTag:1];
    [self.view addSubview:leftrotatebtn];
    [leftrotatebtn addTarget:self action:@selector(Rotate:) forControlEvents:UIControlEventTouchUpInside];

    /**================向右旋转按钮=====================*/
    UIButton *rightrotatebtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [rightrotatebtn setFrame:CGRectMake(225, 400, 40, 40)];
    [rightrotatebtn setBackgroundImage:[UIImage systemImageNamed:@"rotate.right"] forState:UIControlStateNormal];
    [rightrotatebtn setBackgroundImage:[UIImage systemImageNamed:@"rotate.right.fill"] forState:UIControlStateHighlighted];
    [self.view addSubview:rightrotatebtn];
    [rightrotatebtn addTarget:self action:@selector(Rotate:) forControlEvents:UIControlEventTouchUpInside];


    UIButton *nextPageBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [nextPageBtn setFrame:CGRectMake(25, 450, 150, 40)];
    nextPageBtn.backgroundColor = [UIColor orangeColor];
    [nextPageBtn setTitle:@"BaseAnimation" forState:UIControlStateNormal];
    [self.view addSubview:nextPageBtn];
    [nextPageBtn addTarget:self action:@selector(baseAnimation:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *keyFrameAnimationBut=[UIButton buttonWithType:UIButtonTypeCustom];
    [keyFrameAnimationBut setFrame:CGRectMake(225, 450, 150, 40)];
    keyFrameAnimationBut.backgroundColor = [UIColor orangeColor];
    [keyFrameAnimationBut setTitle:@"KeyFrameAnimation" forState:UIControlStateNormal];
    [self.view addSubview:keyFrameAnimationBut];
    [keyFrameAnimationBut addTarget:self action:@selector(keyFromAnimation:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *transitionAmBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [transitionAmBtn setFrame:CGRectMake(25, 550, 150, 40)];
    transitionAmBtn.backgroundColor = [UIColor orangeColor];
    [transitionAmBtn setTitle:@"TransitionAnimation" forState:UIControlStateNormal];
    [self.view addSubview:transitionAmBtn];
    [transitionAmBtn addTarget:self action:@selector(transitionAnimation:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *groupPageBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [groupPageBtn setFrame:CGRectMake(225, 550, 150, 40)];
    groupPageBtn.backgroundColor = [UIColor orangeColor];
    [groupPageBtn setTitle:@"groupPageBtn" forState:UIControlStateNormal];
    [self.view addSubview:groupPageBtn];
    [groupPageBtn addTarget:self action:@selector(grouAnimation:) forControlEvents:UIControlEventTouchUpInside];
}

//控制方向的多个按钮调用同一个方法
-(void)Click:(UIButton *)button
{

    //练习使用frame属性
    //CGRect frame=self.headImageView.frame;

    /**注意，这里如果控制位置的两个属性frame和center同时使用的话，会出现很好玩的效果，注意分析*/
    //练习使用center属性
    CGPoint center=self.headImageView.center;
    switch (button.tag) {
        case ktopbtntag:
            center.y-=30;
            break;
        case kdownbtntag:
            center.y+=30;
            break;
        case kleftbtntag:
            //发现一个bug,之前的问题是因为少写了break,造成了它们的顺序执行，sorry
            //center.x=center.x-30;
            center.x-=50;
            break;
        case krightbtntag:
            center.x+=50;
            break;
    }

    //  self.headImageView.frame=frame;

    //首尾式设置动画效果
    [UIView beginAnimations:nil context:nil];
    self.headImageView.center=center;
    //设置时间
    [UIView setAnimationDuration:2.0];
    [UIView commitAnimations];
    NSLog(@"移动!");

}
-(void)Zoom:(UIButton *)btn
{
    //使用bounds，以中心点位原点进行缩放
    CGRect bounds = self.headImageView.bounds;
    if (btn.tag) {
        bounds.size.height+=30;
        bounds.size.width+=30;
    }
    else
    {
        bounds.size.height-=50;
        bounds.size.width-=50;
    }

    //设置首尾动画
    [UIView beginAnimations:nil context:nil];
    self.headImageView.bounds=bounds;
    [UIView setAnimationDuration:2.0];
    [UIView commitAnimations];
}

-(void)Rotate:(UIButton *)rotate
{
    //位移（不累加）
    //    self.headImageView.transform=CGAffineTransformMakeTranslation(50, 200);
    //缩放
    //    self.headImageView.transform=CGAffineTransformMakeScale(1.2, 10);
    //在原有的基础上位移（是累加的）
    //    self.headImageView.transform=CGAffineTransformTranslate(self.headImageView.transform, 50, 50);
    //在原有的基础上进行缩放
    //    self.headImageView.transform=CGAffineTransformScale(self.headImageView.transform, 1.5, 1.6);

    //    //在原有的基础上进行旋转
    if (rotate.tag) {
        //旋转角度为1/pi，逆时针
        self.headImageView.transform=CGAffineTransformRotate(self.headImageView.transform, -M_1_PI);
    }
    else
    {
        //旋转的角度为pi/2，顺时针
        self.headImageView.transform=CGAffineTransformRotate(self.headImageView.transform, M_PI_2);
    }

}

-(void)baseAnimation:(UIButton *)btn {
    CABaseAnimationViewController *vc = [[CABaseAnimationViewController alloc] init];
    [self.navigationController pushViewController:vc animated: YES];
}

-(void)keyFromAnimation:(UIButton *)btn {
    KeyFrameAnimationVC *vc = [[KeyFrameAnimationVC alloc] init];
    vc.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:vc animated: YES];
}

-(void)transitionAnimation:(UIButton *)btn {
    TransitionAnimationVC *vc = [[TransitionAnimationVC alloc] initWithNibName:@"TransitionAnimationVC" bundle:[NSBundle mainBundle]];
    vc.view.backgroundColor = [UIColor whiteColor];
//    [self presentViewController:vc animated:YES completion:nil];
    [self.navigationController pushViewController:vc animated: YES];
}

-(void)grouAnimation:(UIButton *)btn {
    GroupAnimationVC *vc = [[GroupAnimationVC alloc] init];
    vc.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:vc animated: YES];
}

// #MARK: life cycle

- (void)loadView {
    [super loadView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)dealloc {

}


@end
