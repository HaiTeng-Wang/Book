//
//  TransitionAnimationVC.m
//  UIKitDemo
//
//  Created by Hunter on 2025/7/3.
//

#import "TransitionAnimationVC.h"
#import <WebKit/WebKit.h>

@class WebViewController;

@interface WebViewController : UIViewController

@end

@implementation WebViewController

- (void)viewDidLoad {
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds]; // WebView测试：WebView iOS已经被标志废弃了，性能低，加载慢且会造成内存泄露，会爆内存。这里可以改为WebView，然后去Debug borad 中去查看下Memory。
    webView.backgroundColor = [UIColor whiteColor];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]]];
    [self.view addSubview:webView];
}

@end

typedef void (^BlockType)(void);

@interface TransitionAnimationVC ()
@property(nonatomic,assign) int index;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;

- (IBAction)preOnClick:(UIButton *)sender;
- (IBAction)nextOnClick:(UIButton *)sender;

@property(nonatomic, copy) BlockType block;

@property(nonatomic) id observer;

@end

@implementation TransitionAnimationVC

// 外部可以直接 alloc init的形式创建本CV。 直接走这里，然后走默认走 initWithNibName。 (示例 TransframeViewController line 299 的 transitionAnimation方法) 。
- (instancetype)init{
    self = [super init];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)loadView {
    [super loadView];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.index=1;
   self.observer = [[NSNotificationCenter defaultCenter] addObserverForName:@"需要手动移除" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        NSLog(@"sdfdfd");
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"需要手动移除" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(通知方法) name:@"无需手动移除" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"无需手动移除" object:nil];

    __weak typeof(self) weakSelf = self;
    self.block = ^(){
        __strong typeof(self) strongSelf = weakSelf;
        NSLog(@"这里用了self: %@", strongSelf.iconView);
        // 模拟一个block循环引用，使用instrument没有检测出来，静态分析也没有检测出来。但是如果直接在block内访问self的话，xcode会包循环引用警告。
        // 如果要测试是否产生循环引用，可以看看当前类是否走dealloc方法。（或使用一个三方Lib，例如：有的Lib会交换VC 的pop方法，然后延迟三秒通过weak self调用方法，方法内可以弹窗或断言，如果VC未释放就好执行该方法。）。或者使用XCode的navigation debug board，看下vc个数是否为1。也可以看下其他对象是否为1.不为1证明有多个对象在内存中。
    };

   NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSLog(@"这里有定时器");
       // repearts 为YES的时候，虽然当前类走了deallo方法，但是runloop会一直持有，所以Timer不会释放掉，要在不需要使用timer的时候调用invalidate。
       // 同时需要注意，如果以这种block的时候创建timer，同时timer作为强引用属性，同时在block里访问了self，这时候会产生循环引用环。
    }];
    [timer invalidate];
}

- (id)valueForUndefinedKey:(NSString *)key {
    return nil;
}

+ (BOOL)accessInstanceVariablesDirectly {
    return NO; // default YES
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

- (void)通知方法{
    NSLog(@"通知方法");
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.navigationController pushViewController:[[WebViewController alloc] init] animated:YES];
    self.block();
}

- (void)dealloc {
    // iOS 9 以后，通知无需手动移除，但是block创建的通知需要手动移除，否则虽然走了dealloc方法，但是再次进入vc的时候，会叠加发送通知。因为这个API会导致观察者被系统retain。
    [[NSNotificationCenter defaultCenter] removeObserver:self.observer name:@"需要手动移除" object:nil];

    // 视图控制器的生命周期：
    // PUSH的时候， v2 init一直到viewDidLoad，然后-> v1 viewWillDisappear -> v2 viewWillAppear -> viewWillLayoutSubviews -> viewDidLayoutSubviews -> v1 viewDidDisappear -> v2 viewDidAppear
    // pop的时候， v2 viewWillDisappear -> v1 viewWillAppear -> v2 viewDidDisappear -> v1 viewDidAppear -> v2 dealloc
    // 模态的时候，和v1无关了。但 viewWillLayoutSubviews，viewDidLayoutSubviews 会调用多次（我这里测试是2次）
}


- (IBAction)preOnClick:(UIButton *)sender {
    self.index--;
    if (self.index<1) {
        [self dismissModalViewControllerAnimated:YES];
        self.index=7;
    }
    self.iconView.image=[UIImage imageNamed: [NSString stringWithFormat:@"%d.png",self.index]];

    //创建核心动画
    CATransition *ca=[CATransition animation];
    //告诉要执行什么动画
    //设置过度效果
    ca.type=@"cube";
    //设置动画的过度方向（向左）
    ca.subtype=kCATransitionFromLeft;
    //设置动画的时间
    ca.duration=1.0;
    //添加动画
    [self.iconView.layer addAnimation:ca forKey:nil];
}

//下一张
- (IBAction)nextOnClick:(UIButton *)sender {
    self.index++;
    if (self.index>7) {
        self.index=1;
    }
        self.iconView.image=[UIImage imageNamed: [NSString stringWithFormat:@"%d.png",self.index]];

    //1.创建核心动画
    CATransition *ca=[CATransition animation];

    //1.1告诉要执行什么动画
    //1.2设置过度效果
    ca.type=@"cube";
    //1.3设置动画的过度方向（向右）
    ca.subtype=kCATransitionFromRight;
    //1.4设置动画的时间
    ca.duration=1.0;
    //1.5设置动画的起点
    ca.startProgress=0.5;
    //1.6设置动画的终点
//    ca.endProgress=0.5;

    //2.添加动画
    [self.iconView.layer addAnimation:ca forKey:nil];
}
@end

