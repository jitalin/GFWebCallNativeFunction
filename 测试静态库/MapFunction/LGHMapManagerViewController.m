//
//  ViewController.m
//  LGHMapKit-定位
//
//  Created by 高飞 on 16/11/24.
//  Copyright © 2016年 高飞. All rights reserved.
//

#import "LGHMapManagerViewController.h"
#import "NSObject+HUD.h"
@interface LGHMapManagerViewController ()<CLLocationManagerDelegate,MKMapViewDelegate>
@property (nonatomic,strong) NSString * distanceStr;

@end

@implementation LGHMapManagerViewController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.mapView.hidden = NO;
    self.locationBtn.hidden = NO;
    self.closeBtn.hidden = NO;

}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.locationManager startUpdatingLocation];





}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.locationManager stopUpdatingLocation];
    
    
}
#pragma mark--------正向地理编码返回坐标
- (void)getLocationByAddress:(NSString *)address{
    [self.geocoder geocodeAddressString:address completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        CLPlacemark* placemark = placemarks.firstObject;
       
        CLLocation* location = placemark.location;
        
        self.locationBlock(nil,location);
        
    }];

    
}
#pragma mark-----------反向地理编码返回地址信息
- (void)getAddressByLocation:(CLLocation *)location{
   
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        CLPlacemark* placemark = placemarks.firstObject;
      NSDictionary* addressDic = placemark.addressDictionary;
        self.locationBlock(addressDic,location);
        
    }];
 
    
}
#pragma mark-------添加大头针
- (void)addAnnotationWithCoordinate:(CLLocationCoordinate2D)coordinate Title:(NSString* )title Subtitle:(NSString* )subtitle{
    MKPointAnnotation *annotation0 = [[MKPointAnnotation alloc] init];
    [annotation0 setCoordinate:coordinate];
    [annotation0 setTitle:title];
    [annotation0 setSubtitle:subtitle];
    [self.mapView addAnnotation:annotation0];
  

}
#pragma mark----------判断用户位置是否在某坐标位置的某个范围内
- (void)adjustUserLocationAroundCoordinate:(CLLocationCoordinate2D)coordinate limitedDistance:(double)limitedDistance{
    CLLocation* location = [[CLLocation alloc]initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    
    //画圆,需要在代理方法中设置线宽，背景色等属性
    MKCircle* circle = [MKCircle circleWithCenterCoordinate:location.coordinate radius:limitedDistance];
    [self.mapView addOverlay:circle];
    
    
    
    //单位是米
        double distance = [self.mapView.userLocation.location distanceFromLocation:location];
        self.distanceStr = [NSString stringWithFormat:@"%.2f",distance];
    
     [self.mapView setCenterCoordinate:coordinate animated:YES];
    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(coordinate, limitedDistance*3, limitedDistance*3) animated:YES];
    
        if (distance < limitedDistance) {
            [self showAlert:@"当前用户在该范围内" animationType:MBProgressHUDAnimationFade];
            //显示导航按钮
            self.routeBtn.hidden = NO;

        }else{
            [self showAlert:@"当前用户不在该范围内" animationType:MBProgressHUDAnimationFade];
           //隐藏导航按钮
            self.routeBtn.hidden = YES;
            
        }
    
}
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKCircle class]]) {
        
        MKCircleRenderer *circleView= [[MKCircleRenderer alloc]initWithOverlay:overlay];
        
      circleView.fillColor = [[UIColor colorWithRed:0.479 green:0.244 blue:0.439 alpha:0.180]colorWithAlphaComponent:0.3];
        circleView.strokeColor = [UIColor blueColor];
        
        circleView.lineWidth=2.0;
        return circleView;
        
    }
    return nil;
    

       
}

- (void)getDistanceWithBlock:(DistanceBlock)block{
    _distanceBlock = block;
    
}
- (void)getLocationInfoWithBlock:(LocationBlock)block{
    _locationBlock = block;
    
}
#pragma mark--------CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    if (self.mapView.userLocation.location != nil) {
        [self adjustUserLocationAroundCoordinate:self.targetCoordinate limitedDistance:self.limitedDistance];
        //确定距离后，先停止定位
        [self.locationManager stopUpdatingLocation];
        self.locationBtn.selected = YES;
      
    }
    

}
#pragma mark------------导航功能
- (void)routeFormLocation:(CLLocation*)origion ToLocation:(CLLocationCoordinate2D)target{
   static MKMapItem *currentLocation = nil;
    if (origion) {
        currentLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:origion.coordinate addressDictionary:nil]];
    }
    //默认是起始点是用户当前位置
    currentLocation = [MKMapItem mapItemForCurrentLocation];
    MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:target addressDictionary:nil]];
    [MKMapItem openMapsWithItems:@[currentLocation, toLocation]
                   launchOptions:@{MKLaunchOptionsDirectionsModeKey:
                                       MKLaunchOptionsDirectionsModeDriving,
                                   MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]}];
}
#pragma mark------------MKMapViewDelegate

#pragma mark--------get method
- (CLLocationManager *)locationManager{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc]init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
            [_locationManager requestWhenInUseAuthorization];
        }
        
       
    }return _locationManager;
    
}
- (MKMapView *)mapView{
    if (!_mapView) {
        _mapView = [[MKMapView alloc]initWithFrame:self.view.bounds];
       _mapView.showsUserLocation = YES;
    
        _mapView.delegate = self;
        _mapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;
      
        [self.view addSubview:_mapView];
        
    }return _mapView;
    
}
- (CLGeocoder *)geocoder{
    if (!_geocoder) {
        _geocoder = [[CLGeocoder alloc]init];
        
    }return _geocoder;
}
- (UIButton *)closeBtn{
    if (!_closeBtn) {
        _closeBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, self.mapView.bounds.size.height - 40, self.mapView.bounds.size.width, 40 )];
        [_closeBtn setTitle:@"获取距离范围并退出地图" forState:UIControlStateNormal];
        _closeBtn.backgroundColor = [UIColor redColor];
        [_closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        [self.mapView addSubview:_closeBtn];

        
    }return _closeBtn;
}
- (void)close{
    
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"%@",self.distanceStr);
        self.distanceBlock(self.distanceStr);
        
        
    }];
    
}
- (UIButton *)locationBtn{
    if (!_locationBtn) {
        _locationBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, self.mapView.bounds.size.height -80 , self.mapView.bounds.size.width, 40 )];
        [_locationBtn setTitle:@"停止定位" forState:UIControlStateNormal];
        [_locationBtn setTitle:@"开始定位" forState:UIControlStateSelected];
        _locationBtn.backgroundColor = [UIColor colorWithRed:0.234 green:0.353 blue:0.306 alpha:1.000];
        
        [_locationBtn addTarget:self action:@selector(clickLocationBtn:)forControlEvents:UIControlEventTouchUpInside];
        [self.mapView addSubview:_locationBtn];
       
        
        
    }return _locationBtn;
}
- (void)clickLocationBtn:(UIButton* )btn{
     btn.selected = !btn.selected;
    if (btn.selected) {
        self.mapView.showsUserLocation = NO;
        [self.locationManager stopUpdatingLocation];
        
    }else{
        self.mapView.showsUserLocation = YES;
        [self.locationManager startUpdatingLocation];
        
    }
   
}
- (UIButton *)routeBtn{
    if (!_routeBtn) {
        _routeBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.mapView.bounds.size.width, 40)];
        [_routeBtn setTitle:@"导航" forState:UIControlStateNormal];
        _routeBtn.backgroundColor = [UIColor purpleColor];
        [_routeBtn addTarget:self action:@selector(startRouting:) forControlEvents:UIControlEventTouchUpInside];
        [self.mapView addSubview:_routeBtn];
        
    }return _routeBtn;
    
}
- (void)startRouting:(UIButton*)btn{
    [self routeFormLocation:nil ToLocation:self.targetCoordinate];
    
}
//隐藏状态栏
- (BOOL)prefersStatusBarHidden{
    return YES;
}
@end
