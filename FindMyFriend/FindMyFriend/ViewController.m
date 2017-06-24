//
//  ViewController.m
//  FindMyFriend
//
//  Created by Kinlive on 2017/6/20.
//  Copyright © 2017年 Kinlive Wei. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "RequestMaster.h"
#import "DXHTTPManager.h"
#import "GetFriend.h"
#define GROUPNAME_TAG @"bp102"
//#define USERNAME_TAG     @"Kinwe"
@interface ViewController () <CLLocationManagerDelegate,MKMapViewDelegate>{
    CLLocationManager *locationManager;
    CLLocation *lastLocation;
    NSMutableArray *getFriendArray;
    RequestMaster *requestMaster;
}
@property (weak, nonatomic) IBOutlet UISwitch *switchStatus;
@property (weak, nonatomic) IBOutlet MKMapView *mainMapView;
@property (weak, nonatomic) IBOutlet UILabel *showMyFriend;

@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    locationManager = [CLLocationManager new];
    locationManager.delegate = self;
//    [locationManager requestWhenInUseAuthorization];
    [locationManager requestAlwaysAuthorization];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.activityType = CLActivityTypeFitness;
    //檢查版本是否為IOS 9.0以上,因allowsBackgroundLocationUpdates為IOS9.0版本後才能使用
//    if ([[UIDevice currentDevice].systemVersion floatValue]  >= 9.0) {
        locationManager.allowsBackgroundLocationUpdates = YES;
//        [locationManager requestLocation];
//    }
//    else {
        [locationManager startUpdatingLocation];
//    }
     requestMaster = [RequestMaster new];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    CLLocation *location = locations.lastObject;
    lastLocation = locations.lastObject;
    CLLocationCoordinate2D coordinate = location.coordinate;
    NSLog(@"Current location: %.6f , %.6f", coordinate.latitude , coordinate.longitude);
    //進行一次畫面初始化時的中心定位
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MKCoordinateRegion region ;
        region.center = coordinate ;
        region.span = MKCoordinateSpanMake(0.001, 0.001);
        [_mainMapView setRegion:region  animated: true];
    });
}
//Swith for request Server (on/off).
- (IBAction)openOrCloseReport:(id)sender {
    CLLocationCoordinate2D coordinate = lastLocation.coordinate;
    NSString *strLat = [NSString stringWithFormat:@"%f",coordinate.latitude];
    NSString *strLon = [NSString stringWithFormat:@"%f",coordinate.longitude];
    if(_switchStatus.on){
//        UIAlertController *alert = UIAlertViewStyleDefault;
        //記得加警告視窗詢問user
        //upload.
        [requestMaster startRequestServerWithCoordinateLat:strLat andLon:strLon];
       }else{
        
        NSLog(@"使用者關閉回報!!");
    }
}
//To get friends info's button.
- (IBAction)getMyfriend:(id)sender {
    [requestMaster startGetFriendsInfo];
}

//-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
//    NSLog(@"Error here: .....%@" , error);
//}
@end
