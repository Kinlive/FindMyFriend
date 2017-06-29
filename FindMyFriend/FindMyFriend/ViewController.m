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
#import "CreateAnnotation.h"
#import "CoreDataMaster.h"

@interface ViewController () <CLLocationManagerDelegate,MKMapViewDelegate>
{
    CLLocationManager *locationManager;
    CLLocation *lastLocation;
    RequestMaster *requestMaster;
    NSArray<GetFriend*> *friendsInfo ;//裝入requestMaster回傳的info
    CoreDataMaster *cdMaster;
    MKRoute *route;
    CLLocationCoordinate2D fakeCoordinate;
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
    _mainMapView.delegate = self;
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
    ///=====coredata cdMaster init
    cdMaster = [[CoreDataMaster alloc] initWithSomething];
    
    
    //fake Location define
    fakeCoordinate = CLLocationCoordinate2DMake(24.9643521, 121.1916667 );
    
   
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
    //
    [cdMaster startSaveDataWithLat:coordinate.latitude andLon:coordinate.longitude];
}
//Get Data button
- (IBAction)getData:(id)sender {
    [cdMaster getSaveData];
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
           //做一個提示使用者關閉回報的訊息
        NSLog(@"使用者關閉回報!!");
    }
}
//To get friends info's button.
- (IBAction)getMyfriend:(id)sender {
    friendsInfo = [requestMaster startGetFriendsInfo];
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 3.0* NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^{
        ////////做個時間延遲,因此時還沒載入資料,但friendsInfo卻使用到了會crash
        ///add friends anotation on map ...
        CreateAnnotation *anno = [CreateAnnotation new];
        if (_mainMapView.annotations == nil) {
            [_mainMapView addAnnotations:[anno createAnnotationWithFriendsInfo:friendsInfo]];
        }
        [_mainMapView removeAnnotations:_mainMapView.annotations];
        [_mainMapView addAnnotations:[anno createAnnotationWithFriendsInfo:friendsInfo]];
    });
}
//When mapView get annotations ,it will ask this method...
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if (annotation == mapView.userLocation){
        return nil;
    }
    NSString *identifier = @"friend";
    //dequeueReusableAnnotationViewWithIdentifier
    //尋找畫面上有沒有任何沒有使用的annotationView
    MKPinAnnotationView *result = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if( result == nil){
        result = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
    }else{
        result.annotation = annotation;
    }
    result.canShowCallout = true;
    return  result;
}
//Navigation Button
- (IBAction)navigationButton:(id)sender {
    //1.create coordinate
    CLLocationCoordinate2D resourceCoor = CLLocationCoordinate2DMake(24.9643521, 121.1916667);
    CLLocationCoordinate2D destinationCoor = fakeCoordinate;
    //2.create placemark with coordinate
    MKPlacemark *resourceMark = [[MKPlacemark alloc] initWithCoordinate:resourceCoor];
    MKPlacemark *destinationMark = [[MKPlacemark alloc] initWithCoordinate:destinationCoor];
    //3.create mapItem with placeMark
//    MKMapItem *currenMapItem = [MKMapItem mapItemForCurrentLocation];
    MKMapItem *currenMapItem = [[MKMapItem alloc] initWithPlacemark:resourceMark];
    MKMapItem *destinationMapItem = [[MKMapItem alloc] initWithPlacemark:destinationMark];
    //4.get direction with sourceMapItem and destinationMapItem
    MKDirectionsRequest *dirRequest = [MKDirectionsRequest new];
    dirRequest.source = currenMapItem;
    dirRequest.destination = destinationMapItem;
    MKDirections *direction = [[MKDirections alloc] initWithRequest:dirRequest];
    
    [direction calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
        if ( response == nil) {
            NSLog(@"Error : %@" , error);
            return ;
        }
        route = response.routes[0];
        [_mainMapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
        [_mainMapView setRegion:MKCoordinateRegionForMapRect(route.polyline.boundingMapRect)];
    }];
}
//實現繪製路線
-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = [UIColor redColor];
    renderer.lineWidth = 4.0 ;
    return  renderer;
}
//-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
//    NSLog(@"Error here: .....%@" , error);
//}
- (IBAction)moveLeft:(id)sender {
    fakeCoordinate.latitude -= 0.00005;
}
- (IBAction)moveRight:(id)sender {
    fakeCoordinate.latitude += 00005;
}




@end
