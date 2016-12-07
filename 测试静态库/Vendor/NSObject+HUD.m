//
//  NSObject+HUD.m
//  BaseProject
//
//  Created by tarena on 15/12/17.
//  Copyright © 2015年 tarena. All rights reserved.
//

#import "NSObject+HUD.h"

@implementation NSObject (HUD)
//获取当前屏幕的最上方正在显示的那个view
- (UIView *)currentView{
    UIViewController *vc=[UIApplication sharedApplication].keyWindow.rootViewController;
// vc: 导航控制器, 标签控制器, 普通控制器
    if ([vc isKindOfClass:[UITabBarController class]]) {
        vc = [(UITabBarController *)vc selectedViewController];
    }
    if ([vc isKindOfClass:[UINavigationController class]]) {
        vc = [(UINavigationController *)vc visibleViewController];
    }
    return vc.view;
}

/** 弹出文字提示 */
- (void)showAlert:(NSString *)text animationType:(MBProgressHUDAnimation)animationType{
//防止在非主线程中调用此方法,会报错
    dispatch_async(dispatch_get_main_queue(), ^{
        //    弹出新的提示之前,先把旧的隐藏掉
//        [self hideProgress];
        [MBProgressHUD hideAllHUDsForView:[self currentView] animated:YES];
        MBProgressHUD *progressHUD=[MBProgressHUD showHUDAddedTo:[self currentView] animated:YES];
        progressHUD.animationType = animationType;
        progressHUD.mode = MBProgressHUDModeText;
        progressHUD.labelText = text;
        progressHUD.yOffset = - 150;
        
        [progressHUD hide:YES afterDelay:1.5];
    });
}
/** 显示忙 */
- (void)showBusy{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
//        [self hideProgress];
        [MBProgressHUD hideAllHUDsForView:[self currentView] animated:YES];
        MBProgressHUD *progressHUD=[MBProgressHUD showHUDAddedTo:[self currentView] animated:YES];
        //最长显示30秒
        [progressHUD hide:YES afterDelay:30];
        
    }];

}
/** 隐藏提示 */
- (void)hideProgress{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [MBProgressHUD hideAllHUDsForView:[self currentView] animated:YES];
    }];
}



/**
 *  比较全的提示
 */
- (void)showAlertWithText:(NSString* )text progress:(CGFloat)progress customView:(UIView* )customView mode:(MBProgressHUDMode)mode animationType:(MBProgressHUDAnimation)animationType delayTime:(CGFloat)delayTime{
    dispatch_async(dispatch_get_main_queue(), ^{
        //    弹出新的提示之前,先把旧的隐藏掉
        //        [self hideProgress];
        [MBProgressHUD hideAllHUDsForView:[self currentView] animated:YES];
        MBProgressHUD *progressHUD=[MBProgressHUD showHUDAddedTo:[self currentView] animated:YES];
        progressHUD.animationType = animationType;
        progressHUD.mode = mode;
        switch (mode) {
            case MBProgressHUDModeIndeterminate: {
                
                break;
            }
            case MBProgressHUDModeDeterminate: {
                
                break;
            }
            case MBProgressHUDModeDeterminateHorizontalBar: {
                progressHUD.progress = progress;
                
                break;
            }
            case MBProgressHUDModeAnnularDeterminate: {
                
                progressHUD.progress = progress;
                break;
            }
            case MBProgressHUDModeCustomView: {
                progressHUD.customView = customView;
                break;
            }
            case MBProgressHUDModeText: {
                progressHUD.labelText = text;
       
                progressHUD.cornerRadius = 10;
                progressHUD.minSize = CGSizeMake(200, 60);
                break;
            }
        }
        
        
        [progressHUD hide:YES afterDelay:delayTime];
    });
}
@end








