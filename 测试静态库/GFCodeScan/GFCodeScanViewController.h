//
//  GFCodeScanViewController.h
//  GFCodeScan
//
//  Created by 高飞 on 16/12/6.
//  Copyright © 2016年 高飞. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^DecodeBlock)(NSString* text);
@interface GFCodeScanViewController : UIViewController
@property (nonatomic,copy) DecodeBlock decodeBlock;
/**
 *  获取二维码扫描后的信息
 *
 *  @param decodeBlock decodeBlock 
 */
- (void)getInfoWithDecodeBlock:(DecodeBlock)decodeBlock;

@end
