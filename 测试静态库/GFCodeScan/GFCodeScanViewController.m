//
//  GFCodeScanViewController.m
//  GFCodeScan
//
//  Created by 高飞 on 16/12/6.
//  Copyright © 2016年 高飞. All rights reserved.
//

#import "GFCodeScanViewController.h"
@import AVFoundation;
#import "GFShapeView.h"
@interface GFCodeScanViewController () <AVCaptureMetadataOutputObjectsDelegate> {
    AVCaptureVideoPreviewLayer *_previewLayer;
    GFShapeView *_boundingBox;
    NSTimer *_boxHideTimer;
    UILabel *_decodedMessage;
    UIButton* _finishBtn;
    UIButton* _closeBtn;
}

@end

@implementation GFCodeScanViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create a new AVCaptureSession
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    
    // Want the normal device
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if(input) {
        // Add the input to the session
        [session addInput:input];
    } else {
        NSLog(@"error: %@", error);
        return;
    }
    
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    // Have to add the output before setting metadata types
    [session addOutput:output];
    // What different things can we register to recognise?
    NSLog(@"%@", [output availableMetadataObjectTypes]);
    // We're only interested in QR Codes
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    // This VC is the delegate. Please call us on the main queue
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // Display on screen
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer.bounds = self.view.bounds;
    _previewLayer.position = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    [self.view.layer addSublayer:_previewLayer];
    
    
    // Add the view to draw the bounding box for the UIView
    _boundingBox = [[GFShapeView alloc] initWithFrame:self.view.bounds];
    //二维码那个视图背景色
    _boundingBox.backgroundColor = [UIColor clearColor];
    //先隐藏
    _boundingBox.hidden = YES;
    [self.view addSubview:_boundingBox];
    
    // Add a label to display the resultant message
    _decodedMessage = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 75, CGRectGetWidth(self.view.bounds), 75)];
    _decodedMessage.numberOfLines = 0;
    _decodedMessage.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.9];
    _decodedMessage.textColor = [UIColor darkGrayColor];
    _decodedMessage.textAlignment = NSTextAlignmentCenter;
  
    
    [self.view addSubview:_decodedMessage];
    _finishBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,CGRectGetHeight(self.view.bounds) - 115, CGRectGetWidth(self.view.bounds), 40)];
    [_finishBtn setTitle:@"Mission accomplished!" forState:UIControlStateNormal];
    _finishBtn.backgroundColor = [UIColor colorWithRed:0.132 green:0.456 blue:0.142 alpha:1.000];
    [_finishBtn addTarget:self action:@selector(clickFinishBtn:) forControlEvents:UIControlEventTouchUpInside];
    _finishBtn.hidden = YES;
    
    [self.view addSubview:_finishBtn];
    _closeBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,0, CGRectGetWidth(self.view.bounds), 40)];
    [_closeBtn setTitle:@"关闭退出" forState:UIControlStateNormal];
    _closeBtn.backgroundColor = [UIColor colorWithRed:0.241 green:0.209 blue:0.182 alpha:1.000];
    [_closeBtn addTarget:self action:@selector(clickFinishBtn:) forControlEvents:UIControlEventTouchUpInside];
    _closeBtn.hidden = NO;
    [self.view addSubview:_closeBtn];
    
    // Start the AVSession running
    [session startRunning];
}
- (void)clickFinishBtn:(UIButton* )btn{
   
    [self dismissViewControllerAnimated:YES completion:^{
         self.decodeBlock(_decodedMessage.text);
    }];
}
#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    for (AVMetadataObject *metadata in metadataObjects) {
        if ([metadata.type isEqualToString:AVMetadataObjectTypeQRCode]) {
            // Transform the meta-data coordinates to screen coords
            AVMetadataMachineReadableCodeObject *transformed = (AVMetadataMachineReadableCodeObject *)[_previewLayer transformedMetadataObjectForMetadataObject:metadata];
            //1.四方形的frame 和二维码相同
            // Update the frame on the _boundingBox view, and show it
            _boundingBox.frame = transformed.bounds;
            //2.显示
            _boundingBox.hidden = NO;
            _closeBtn.hidden = YES;
            // Now convert the corners array into CGPoints in the coordinate system
            //  of the bounding box itself
            //2.四个角点复制到四方形
            NSArray *translatedCorners = [self translatePoints:transformed.corners
                                                      fromView:self.view
                                                        toView:_boundingBox];
            
            // Set the corners array
            _boundingBox.corners = translatedCorners;
            
            // Update the view with the decoded text
            _decodedMessage.text = [transformed stringValue];
            [self changeMessageBackGroudColor];
            
     
            // Start the timer which will hide the overlay
            [self startOverlayHideTimer];
        }
    }
}
#pragma mark-----改变label的背景色
- (void)changeMessageBackGroudColor{
    
    _decodedMessage.backgroundColor = ![_decodedMessage.text isEqualToString:@""]?[UIColor redColor]:[UIColor colorWithWhite:0.8 alpha:0.9];
    _finishBtn.hidden = [_decodedMessage.text isEqualToString:@""]?YES:NO;
    _closeBtn.hidden = !_finishBtn.hidden;
    
    
}
#pragma mark - Utility Methods
- (void)startOverlayHideTimer
{
    // Cancel it if we're already running
    if(_boxHideTimer) {
        [_boxHideTimer invalidate];
    }
    
    // Restart it to hide the overlay when it fires
    _boxHideTimer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                     target:self
                                                   selector:@selector(removeBoundingBox:)
                                                   userInfo:nil
                                                    repeats:NO];
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    self.decodeBlock(_decodedMessage.text);
    [_boxHideTimer invalidate];
    _boxHideTimer = nil;
    NSLog(@"%@",_boxHideTimer);
}
- (void)removeBoundingBox:(id)sender
{
    // Hide the box and remove the decoded text
    _boundingBox.hidden = YES;
    _decodedMessage.text = @"";
    [self changeMessageBackGroudColor];
    
}

- (NSArray *)translatePoints:(NSArray *)points fromView:(UIView *)fromView toView:(UIView *)toView
{
    NSMutableArray *translatedPoints = [NSMutableArray new];
    
    // The points are provided in a dictionary with keys X and Y
    for (NSDictionary *point in points) {
        // Let's turn them into CGPoints
        CGPoint pointValue = CGPointMake([point[@"X"] floatValue], [point[@"Y"] floatValue]);
        // Now translate from one view to the other
        CGPoint translatedPoint = [fromView convertPoint:pointValue toView:toView];
        // Box them up and add to the array
        [translatedPoints addObject:[NSValue valueWithCGPoint:translatedPoint]];
    }
    
    return [translatedPoints copy];
}
#pragma mark----------获取扫描后的信息
- (void)getInfoWithDecodeBlock:(DecodeBlock)decodeBlock{
    self.decodeBlock = decodeBlock;
    
}
//隐藏状态栏
- (BOOL)prefersStatusBarHidden{
    return YES;
}
//设置竖屏
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
