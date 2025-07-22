//
//  HomeViewController.m
//  UIKitDemo
//
//  Created by Hunter on 2025/7/1.
//

#import "HomeViewController.h"
#import "HomeViewController+Testing.h"
#import "TransframeViewController.h"

@protocol HomeDelegate <NSObject>

- (void)delegatehome;

@end

// MARK: Category & Extention 练习
@interface HomeViewController ()<HomeDelegate>{ // .m 中的延展（可以生命成员变量和方法，成员默认是private的，只有当前类能访问。分类子类都不可以）
    // OC点语法和变量作用域 https://www.cnblogs.com/wendingding/p/3705658.html
    NSString *_sex; // Instance variable '_sex' is private。默认私有，只有当前类能访问。分类子类都不可以访问。
    @protected // 只有当前类可和子类能访问，分类也不可以访问。
    int _age;
    @public
    bool _isAccess; // 在延展中显式的声明public（相当于protected），也只有当前类可和子类能访问，分类也不可以访问。
}

@property (nonatomic, copy) NSString *name; // property是 protected 的，但是 @property 生成的_iva 的访问级别是private。

-(void)extentionTest;

@end

@interface HomeViewController () {
}
@end

@implementation HomeViewController

- (instancetype)init{
    self = [super init];
    self.name = @"init";
    return self;
}

// 当前XIB控制器在XIB或SB中初始化，会走这里。
- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    self.name = @"initWithCoder";
    return self;
}

// 当前XIB控制器，用代码的形式初始化（VCA ->想要跳转本VC，使用code的方式初始化本VC），走这里。
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.name = @"initWithNibName";
    return self;
}

// 从Nib中唤醒的时候调用，可以从写此方法进行一些空间的初始配置，如果不方便在xib上配置的话。
// 顺序： 1. initWithCoder 2.awakeFromNib
// 代码的形式初始化本 VC (initWithNibName) 不走这个方法。
- (void)awakeFromNib {
    [super awakeFromNib];
    self.name = @"awakeFromNib";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.name = @"hello";
    self.view.backgroundColor = [UIColor orangeColor];
//    NSLog(@"%ld", (long)[self.delegate incrementForCount:10]);
//    [self delegatehome];
}

- (void)viewDidLoadff {

}

- (void)dealloc {

    
}

- (IBAction)goNextPage:(UIButton *)sender {
    TransframeViewController *transframeVC = [[TransframeViewController alloc] initWithNibName:@"TransframeViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:transframeVC animated:YES];
}

-(void)extentionTest {
    [self viewDidLoadff];

}

@end


@interface SonVC : HomeViewController

@end


@implementation SonVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.name = @"fdsfds";
//    _name = @""; Instance variable '_name' is private
    _age = 100;
    self->_age = HHTT;
    _isAccess = YES;
    [self testing];
    [self delegatehome];
}

-(void)extentionTest {

}

@end
