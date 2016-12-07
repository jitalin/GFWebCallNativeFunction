//
//  PhotoPickManager.m
//  LGHCamera
//
//  Created by 高飞 on 16/11/23.
//  Copyright © 2016年 高飞. All rights reserved.
//

#import "PhotoPickManager.h"

@interface PhotoPickManager ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

{
    UIViewController            *_vc;
    CallBackBlock                 _callBackBlock;
}
@end

@implementation PhotoPickManager

+ (PhotoPickManager*)pickManager{
    return [[self alloc]init];
    
}
#pragma mark-------公开接口
- (void)presentPickerForRecordVideo:(BOOL)isRecordVideo target:(UIViewController *)vc callBackBlock:(CallBackBlock)callBackBlock
{
    self.isVideo = isRecordVideo;
    _vc = vc;
    _callBackBlock = callBackBlock;
    NSLog(@"%@",self.imagePicker.delegate);
    
    [_vc presentViewController:self.imagePicker animated:YES completion:nil];
    
    

}

#pragma mark - UIImagePickerController代理方法
//完成

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {//如果是拍照
        UIImage *image;
        //如果允许编辑则获得编辑后的照片，否则获取原始照片
        if (self.imagePicker.allowsEditing) {
            image=[info objectForKey:UIImagePickerControllerEditedImage];//获取编辑后的照片
        }else{
            image=[info objectForKey:UIImagePickerControllerOriginalImage];//获取原始照片
        }
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);//保存到相簿
        NSData* data = UIImagePNGRepresentation(image);
        [data writeToFile:self.photoPath atomically:YES];
        
    }else if([mediaType isEqualToString:(NSString *)kUTTypeMovie]){//如果是录制视频
        NSURL *url=[info objectForKey:UIImagePickerControllerMediaURL];//视频路径
        NSString *urlStr=[url path];
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(urlStr)) {
            //保存视频到相簿，注意也可以使用ALAssetsLibrary来保存
            UISaveVideoAtPathToSavedPhotosAlbum(urlStr, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);//保存视频到相簿
        
        }
        
    }
    
    [_vc dismissViewControllerAnimated:YES completion:^{
        // block回调
        _callBackBlock(info, self.photoPath);
        //NSLog(@"退出");
    }];
}
//视频保存后的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {
       // NSLog(@"保存视频过程中发生错误，错误信息:%@",error.localizedDescription);
    }else{
        
        // NSLog(@"视频保存成功,视频路径为%@",videoPath);
        [_vc dismissViewControllerAnimated:YES completion:^{
            // block回调
        }];
   
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [_vc dismissViewControllerAnimated:YES completion:nil];
    
}
#pragma mark - get method私有方法
-(UIImagePickerController *)imagePicker{
    if (!_imagePicker) {
        _imagePicker=[[UIImagePickerController alloc]init];
        _imagePicker.allowsEditing=YES;//允许编辑
        _imagePicker.delegate=self;//设置代理，检测操作
        _imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;//设置image picker的来源，这里设置为摄像头
        _imagePicker.cameraDevice=UIImagePickerControllerCameraDeviceRear;//设置使用哪个摄像头，这里设置为后置摄像头
        if (self.isVideo) {
            _imagePicker.mediaTypes=@[(NSString *)kUTTypeMovie];
            _imagePicker.videoQuality=UIImagePickerControllerQualityTypeIFrame1280x720;
            _imagePicker.cameraCaptureMode=UIImagePickerControllerCameraCaptureModeVideo;//设置摄像头模式（拍照，录制视频）
            
        }else{
            _imagePicker.cameraCaptureMode=UIImagePickerControllerCameraCaptureModePhoto;
        }
        
    }
    return _imagePicker;
}
- (NSString *)photoPath{
    if (!_photoPath) {
        NSString* documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES).lastObject;
        _photoPath = [documentPath stringByAppendingPathComponent:@"photo.png"];
    }return _photoPath;
    
}


@end