//
//  NSObject+HUD.h
//  BaseProject
//
//  Created by tarena on 15/12/17.
//  Copyright © 2015年 tarena. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MBProgressHUD.h"

@interface NSObject (HUD)
//默认

/** 弹出文字提示 */
- (void)showAlert:(NSString *)text animationType:(MBProgressHUDAnimation)animationType;


/** 显示忙 */
- (void)showBusy;
/** 隐藏提示 */
- (void)hideProgress;



//比较全的
- (void)showAlertWithText:(NSString* )text progress:(CGFloat)progress customView:(UIView* )customView mode:(MBProgressHUDMode)mode animationType:(MBProgressHUDAnimation)animationType delayTime:(CGFloat)delayTime;
@end











