//
//  ViewController.h
//  LGHMapKit-定位
//
//  Created by 高飞 on 16/11/24.
//  Copyright © 2016年 高飞. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
typedef void (^LocationBlock)(NSDictionary* addressDic,CLLocation* location);

typedef void(^DistanceBlock)(NSString* distanceStr);

@interface LGHMapManagerViewController : UIViewController


@property (nonatomic,strong) CLLocationManager *locationManager;
@property (nonatomic,strong) CLGeocoder *geocoder;
@property (nonatomic,strong) MKMapView *mapView;
/**
 *  目标坐标经纬度
 */
@property (nonatomic,assign)CLLocationCoordinate2D targetCoordinate;
/**
 *  限制距离范围（米）
 */
@property (nonatomic,assign) double limitedDistance;
@property (nonatomic,copy) DistanceBlock distanceBlock;
@property (nonatomic,copy) LocationBlock locationBlock;
/**
 *  退出按钮
 */
@property (nonatomic,strong) UIButton *closeBtn;
/**
 *  定位按钮
 */
@property (nonatomic,strong) UIButton *locationBtn;
/**
 *  导航按钮
 */
@property (nonatomic,strong) UIButton *routeBtn;
/**
 *  正向地理编码
 *
 *  @param address 地址信息
 *
 *  @return 地理坐标
 */
- (void)getLocationByAddress:(NSString* )address;
/**
 *  反向地理编码（获取地址信息）
 *
 *  @param location 地理坐标
 */
- (void)getAddressByLocation:(CLLocation*)location;
/**
 *  添加大头针
 *
 *  @param coordinate 目标坐标经纬度
 *  @param title      标题
 *  @param subtitle   子标题
 */

- (void)addAnnotationWithCoordinate:(CLLocationCoordinate2D)coordinate Title:(NSString* )title Subtitle:(NSString* )subtitle;

/**
 *  获取返回的数据
 *
 *  @param block
 */
- (void)getDistanceWithBlock:(DistanceBlock)block;
/**
 *  获取地理位置或地址信息
 *
 *  @param block LocationBlock
 */
- (void)getLocationInfoWithBlock:(LocationBlock)block;

@end

