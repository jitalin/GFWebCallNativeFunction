//
//  ExampleUIWebViewController.m
//  ExampleApp-iOS
//
//  Created by Marcus Westin on 1/13/14.
//  Copyright (c) 2014 Marcus Westin. All rights reserved.
//

#import "ExampleUIWebViewController.h"
#import "WebViewJavascriptBridge.h"
#import "GFCodeScanViewController.h"
#import "PhotoPickManager.h"
#import "LGHMapManagerViewController.h"

@interface ExampleUIWebViewController ()<UIWebViewDelegate>
@property WebViewJavascriptBridge* bridge;

@end

@implementation ExampleUIWebViewController

- (void)viewWillAppear:(BOOL)animated {
    if (_bridge) { return; }
    
    UIWebView* webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:webView];
    
    [WebViewJavascriptBridge enableLogging];

    //搭桥
    _bridge = [WebViewJavascriptBridge bridgeForWebView:webView];
    [_bridge setWebViewDelegate:self];
    
    //testObjcCallback很重要(注册桥的Key)
    //1.二维码扫码功能
    [self registerQRCodeScan];

    //2.拍照功能
    [self registerTakePhoto];

    //3.视频录制

    [self registerVideoRecord];
  
    //4.地图
    [self registerMap];
    
    //加载网页
    [self loadExamplePage:webView HtmlName:@"index.html"];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
   
}
- (void)webViewDidStartLoad:(UIWebView *)webView {
    //NSLog(@"webViewDidStartLoad");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    //NSLog(@"webViewDidFinishLoad");
}

#pragma mark-------加载网页
- (void)loadExamplePage:(UIWebView*)webView  HtmlName:(NSString*)htmlName{
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:htmlName ofType:nil];
    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [webView loadHTMLString:appHtml baseURL:baseURL];
}
#pragma mark--------二维码扫码
- (void)registerQRCodeScan{
    [_bridge registerHandler:@"GFCodeScanBack" handler:^(id data, WVJBResponseCallback responseCallback) {
        //这里可以调用扫码功能
        
        GFCodeScanViewController *scanner = [[GFCodeScanViewController alloc]init];
        
        
        [self presentViewController:scanner animated:YES completion:^{
            [scanner getInfoWithDecodeBlock:^(NSString *text) {
                responseCallback(text);
            }];
        }];
        
        }];
        


}
#pragma mark------拍照
- (void)registerTakePhoto{
    [_bridge registerHandler:@"takePhotoBack" handler:^(id data, WVJBResponseCallback responseCallback) {
        //调用拍照接口
        //1>.创建PhotoPickManager
        PhotoPickManager* pickManager = [[PhotoPickManager alloc]init];
        
        //2>.调用接口
        [pickManager presentPickerForRecordVideo:NO target:self callBackBlock:^(NSDictionary *infoDict, NSString *photoPath){
            NSLog(@"%@",photoPath);
            //这个可能是xcode的bug,省去不能进入代理方法
            //获取图片
            UIImage* image;
            if (pickManager.imagePicker.allowsEditing) {
                //获取编辑后的照片
                image = [infoDict objectForKey:UIImagePickerControllerEditedImage];
                
            }else{
                image = [infoDict objectForKey:UIImagePickerControllerOriginalImage];
            }
            responseCallback(photoPath);
        }];
    }];
}
#pragma mark-----视频录制
- (void)registerVideoRecord{
    [_bridge registerHandler:@"videoRecordBack" handler:^(id data, WVJBResponseCallback responseCallback) {
        //调用拍照接口
        //1>.创建PhotoPickManager
        PhotoPickManager* pickManager = [[PhotoPickManager alloc]init];
        [pickManager presentPickerForRecordVideo:YES target:self callBackBlock:^(NSDictionary *infoDict, NSString *photoPath) {
             //返回本地视频路径
            UIImage* image;
            if (pickManager.imagePicker.allowsEditing) {
                //获取编辑后的照片
                image = [infoDict objectForKey:UIImagePickerControllerEditedImage];
                
            }else{
                image = [infoDict objectForKey:UIImagePickerControllerOriginalImage];
            }

            NSURL *videoUrl=[infoDict objectForKey:UIImagePickerControllerMediaURL];
            NSString *videoStr = videoUrl.path;
            NSLog(@"保存的视频地址：%@",videoStr);
            responseCallback(videoStr);

           

        }];
        
    }];
}
#pragma mark----地图
- (void)registerMap{

    [_bridge registerHandler:@"mapBack" handler:^(id data, WVJBResponseCallback responseCallback) {
        //1.创建LGHMapManagerViewController实例
        LGHMapManagerViewController* mapVC = [[LGHMapManagerViewController alloc]init];
        //2.进入地图界面
    [self presentViewController:mapVC animated:YES completion:^{
        /**
        //方式一：传入一个地理坐标 3.添加目标坐标经纬度
        CLLocationCoordinate2D coordinate =  CLLocationCoordinate2DMake(29.455686, 106.59);
        mapVC.targetCoordinate = coordinate;
        //4.添加大头针
        [mapVC addAnnotationWithCoordinate:coordinate Title:@"title" Subtitle:@"subtitle"];
        */
        //方式二：正向地理编码获取地理坐标
        [mapVC getLocationByAddress:@"杭州信雅达大厦"];
        [mapVC getLocationInfoWithBlock:^(NSDictionary *addressDic, CLLocation* location) {
            NSLog(@"location:%@",location);
            mapVC.targetCoordinate = location.coordinate;
            //4.添加大头针
            [mapVC addAnnotationWithCoordinate:location.coordinate Title:@"杭州信雅达大厦" Subtitle:@"subtitle"];
        }];
        //5.设置限制范围
        mapVC.limitedDistance = 500;
        //获取返回的数据
        [mapVC getDistanceWithBlock:^(NSString *distanceStr) {
            
            responseCallback([NSString stringWithFormat:@"用户与目标位置的距离为%@米",distanceStr]);
        }];
        
    }];
        
    }];

}

@end
