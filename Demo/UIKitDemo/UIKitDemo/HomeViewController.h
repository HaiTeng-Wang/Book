//
//  HomeViewController.h
//  UIKitDemo
//
//  Created by Hunter on 2025/7/1.
//

#import <UIKit/UIKit.h>
//#import "UIKitDemo-Swift.h"

@interface HomeViewController : UIViewController
//@property (nonatomic, weak) id<ViewControlDelegate> delegate; // 关于OC语言 @property @synthesize和id。（看我的gitbub，和这里快速回顾https://www.cnblogs.com/wendingding/p/3706430.html）
@end

@interface HomeViewController () {
    NSString *fullyName; // .h 中的i延展默认是public的，分类都可以访问。
}
@end
