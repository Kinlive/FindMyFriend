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
#import "DrawRouteMaster.h"

@interface ViewController () <CLLocationManagerDelegate,MKMapViewDelegate>
{
    CLLocationManager *locationManager;
    CLLocation *lastLocation;
    RequestMaster *requestMaster;
    NSArray<GetFriend*> *friendsInfo ;//裝入requestMaster回傳的info
    CoreDataMaster *cdMaster;
    MKRoute *route;//
    DrawRouteMaster *drawMaster;//
    NSMutableArray<CLLocation*> *lastLocationsArray;
    NSTimer *reportTimer;
    NSTimer *saveDataTimer;
    NSTimer *sportTimer;
    MKPointAnnotation *whichFriend;
}
@property (weak, nonatomic) IBOutlet UISwitch *switchStatus;
@property (weak, nonatomic) IBOutlet MKMapView *mainMapView;
@property (weak, nonatomic) IBOutlet UISwitch *saveSWStatus;
@property (weak, nonatomic) IBOutlet UISwitch *sportSWStatus;
@property (weak, nonatomic) IBOutlet UILabel *deviceVersion;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //Get user device version to do something check.
    NSString *iosVersion = [UIDevice currentDevice].systemVersion;
    _deviceVersion.text = iosVersion;
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
    //RequestMaster init
     requestMaster = [RequestMaster new];
    ///=====coredata cdMaster init
    cdMaster = [[CoreDataMaster alloc] initWithSomething];
    //DrawRouteMaster init
    drawMaster = [[DrawRouteMaster alloc] init];
   ////for polyline define
    lastLocationsArray = [[NSMutableArray alloc] init];
}
-(void)startUpdateLocation{
    [locationManager startUpdatingLocation];
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
    //for polyline use
    [lastLocationsArray addObject: lastLocation];
    //進行一次畫面初始化時的顯示比例
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MKCoordinateRegion region ;
        region.center = coordinate ;
        region.span = MKCoordinateSpanMake(0.01, 0.01);
        [_mainMapView setRegion:region  animated: true];
    });
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
        //
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"若開啟時將會每分鐘進行使用者座標回報的動作,確定?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
           
            //        UIAlertController *alert = UIAlertViewStyleDefault;
            //記得加警告視窗詢問user
            //upload.
            [requestMaster startRequestServerWithCoordinateLat:strLat andLon:strLon];
            reportTimer = [NSTimer scheduledTimerWithTimeInterval:60 repeats:YES block:^(NSTimer * _Nonnull timer) {
                [requestMaster startRequestServerWithCoordinateLat:strLat andLon:strLon];
            }];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [_switchStatus setOn:NO];
        }];
        [alert addAction:cancel];
        [alert addAction:ok];
         [self presentViewController:alert animated:true completion:nil];
       }else if(!_switchStatus.on){
           //做一個提示使用者關閉回報的訊息
        NSLog(@"使用者關閉回報!!");
            [reportTimer invalidate];
            reportTimer = nil;
    }
}
- (IBAction)saveData:(id)sender {
    if (_saveSWStatus.on){
        [cdMaster startSaveDataWithLat:lastLocation.coordinate.latitude andLon:lastLocation.coordinate.longitude];
        saveDataTimer = [NSTimer scheduledTimerWithTimeInterval:30.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
            [cdMaster startSaveDataWithLat:lastLocation.coordinate.latitude andLon:lastLocation.coordinate.longitude];
        }];
    }else {
        [saveDataTimer invalidate];
        saveDataTimer = nil;
    }
}
- (IBAction)startSportMode:(id)sender {
    if (_sportSWStatus.on) {
        //在開始顯示前先將原先抓取到的位置清除
        lastLocationsArray = [NSMutableArray new];
        sportTimer = [NSTimer scheduledTimerWithTimeInterval:2 repeats:YES block:^(NSTimer * _Nonnull timer) {
            //抓到中心點
            MKCoordinateRegion region ;
            region.center = lastLocation.coordinate ;
            region.span = MKCoordinateSpanMake(0.005, 0.005);
            [_mainMapView setRegion:region  animated: true];
            //顯示運動軌跡
            [self showUserRoute];
        }];
    }else{
        [sportTimer invalidate];
        sportTimer = nil;
    }
}

//To get friends info's button.
- (IBAction)getMyfriend:(id)sender {
    friendsInfo = [requestMaster startGetFriendsInfo];
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 2.0* NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^{
        ////////做個時間延遲,因此時還沒載入資料,但friendsInfo卻使用到了會crash
        ///add friends anotation on map ...
        CreateAnnotation *anno = [CreateAnnotation new];
        if (_mainMapView.annotations != nil) {
            //avoid annotations when refresh be more
            [_mainMapView removeAnnotations:_mainMapView.annotations];
        }
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
//    whichFriend = result.annotation;///
    //prepare RightCallOutAccessoryView.
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(0, 0, 40, 50);
    [button setTitle:@"GO!" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(findFriendButton:) forControlEvents:UIControlEventTouchUpInside];
    result.leftCalloutAccessoryView = button;
    return  result;
}
//Get which friends user selected..
-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    whichFriend = view.annotation;
}
//for friend annotation use...
-(void)findFriendButton:(id)sender{
    
    [self startNavigationWith:lastLocation.coordinate and:whichFriend.coordinate];

}
////Navigation method
-(void)startNavigationWith:(CLLocationCoordinate2D)resourceCoor and: (CLLocationCoordinate2D)destinationCoor{
    if(route != nil){
        [_mainMapView removeOverlay:route.polyline];
    }
    //1.create coordinate
    MKDirectionsRequest *dirRequest = [drawMaster getCoordinateWith:resourceCoor and:destinationCoor];
    MKDirections *direction = [[MKDirections alloc] initWithRequest:dirRequest];
    [direction calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
        if ( response == nil) {
            NSLog(@"Error : %@" , error);
            return ;
        }
        route = response.routes.lastObject;
        [_mainMapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
        [_mainMapView setRegion:MKCoordinateRegionForMapRect(route.polyline.boundingMapRect)];
    }];
}
//路線繪製器
-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = [UIColor redColor];
    renderer.lineWidth = 1.0 ;
    return  renderer;
}
//-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
//    NSLog(@"Error here: .....%@" , error);
//}
//這個方法可以不需要,
-(void)showUserRoute{
    [_mainMapView addOverlay:[drawMaster showUserSportRouteOn:lastLocationsArray]];
    [_mainMapView rendererForOverlay:[drawMaster showUserSportRouteOn:lastLocationsArray]];
}




@end
