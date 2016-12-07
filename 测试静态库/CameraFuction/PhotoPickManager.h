//
//  PhotoPickManager.h
//  LGHCamera
//
//  Created by 高飞 on 16/11/23.
//  Copyright © 2016年 高飞. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>

typedef void(^CallBackBlock)(NSDictionary *infoDict, NSString* photoPath);

@interface PhotoPickManager : NSObject
/**
 *  是否录制视频,YES表示录制视频，NO代表拍照
 */
@property (assign,nonatomic) BOOL isVideo;
@property (strong,nonatomic) UIImagePickerController *imagePicker;

@property (strong ,nonatomic) AVPlayer *player;//播放器，用于录制完视频后播放视频
/**
 *  图片路径
 */
@property (nonatomic,strong) NSString * photoPath;


+ (PhotoPickManager*)pickManager;
/**
 *  调用相机功能
 *
 *  @param isRecordVideo 是否录制视频
 *  @param vc            调用的VC
 *  @param callBackBlock 数据回调
 */
- (void)presentPickerForRecordVideo:(BOOL)isRecordVideo target:(UIViewController *)vc callBackBlock:(CallBackBlock)callBackBlock;


@end

