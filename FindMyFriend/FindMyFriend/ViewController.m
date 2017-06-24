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
#import "GetFriend.h"
@interface ViewController () <CLLocationManagerDelegate,MKMapViewDelegate>{
    CLLocationManager *locationManager;
    CLLocation *lastLocation;
    RequestMaster *requestMaster;
    NSArray *friendsInfo ;//裝入requestMaster回傳的info
    int countFriends;//計算目前得到的是第幾個朋友
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
    countFriends = 0;
    
    
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
    //進行一次畫面初始化時的顯示比例
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MKCoordinateRegion region ;
        region.center = coordinate ;
        region.span = MKCoordinateSpanMake(0.01, 0.01);
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
    friendsInfo = [requestMaster getInfoResult];
    
    ///add friends anotation on map ...
    double lat = [friendsInfo[countFriends][@"lat"] doubleValue];
    double lon = [friendsInfo[countFriends][@"lon"] doubleValue];
    //Create friends coordinate
    CLLocationCoordinate2D lastCoor = lastLocation.coordinate;
    MKPointAnnotation *lastAnno = [MKPointAnnotation new];
    lastCoor.latitude += 0.005;
    lastCoor.longitude += 0.005;
    lastAnno.coordinate = lastCoor;
    
    //.....
    CLLocationCoordinate2D friendCoord = {(lat),(lon)};
    MKPointAnnotation *friendAnno = [MKPointAnnotation new];
    friendAnno.coordinate = friendCoord;
    friendAnno.title = friendsInfo[countFriends][@"friendName"];
    friendAnno.subtitle = friendsInfo[countFriends][@"dateTime"];
    [_mainMapView addAnnotation:friendAnno];
    [_mainMapView addAnnotation:lastAnno];
    
}
//Add friends anotation ...
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if (annotation == mapView.userLocation){
        return nil;
    }
    NSString *identifier = friendsInfo[countFriends][@"friendName"];
    MKPinAnnotationView *result = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if( result == nil){
        result = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
    }else{
        result.annotation = annotation;
    }
    countFriends += 1 ;
    result.canShowCallout = true;
    return  result;
    
}

//-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
//    NSLog(@"Error here: .....%@" , error);
//}
@end
