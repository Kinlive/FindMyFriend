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
#import "AFNetworking.h"
@interface ViewController () <CLLocationManagerDelegate,MKMapViewDelegate>{
    CLLocationManager *locationManager;
}
@property (weak, nonatomic) IBOutlet UISwitch *switchStatus;

@property (weak, nonatomic) IBOutlet MKMapView *mainMapView;

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
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    CLLocation *location = locations.lastObject;
    CLLocationCoordinate2D coordinate = location.coordinate;
    NSLog(@"Current location: %.6f , %.6f", coordinate.latitude , coordinate.longitude);
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MKCoordinateRegion region ;
        region.center = coordinate ;
        region.span = MKCoordinateSpanMake(0.001, 0.001);
        [_mainMapView setRegion:region  animated: true];
    });
}
- (IBAction)openOrCloseReport:(id)sender {
    CLLocationCoordinate2D coordinate = locationManager.location.coordinate;
    if(_switchStatus.on){
//        UIAlertController *alert = UIAlertViewStyleDefault;
        //記得加警告視窗詢問user
        //upload.
//        NSURL *url = [NSURL URLWithString:@""];
//        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
//        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
//        NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
//        NSData *uploadDate = ;
        //AFNetworking 應用基本流程
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSDictionary *parameters = @{
                                     @"GroupName":@"bp102",
                                     @"UserName":@"Kinwe",
                                     @"Lat":@"latitude",
                                     @"Lon":@"lontitude"
                                     };
        [manager POST:@"http://class.softarts.cc/FindMyFriends/updateUserLocation.php" parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            NSLog(@"JSON:%@", responseObject);
        } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            NSLog(@"Error: %@", error);
        }];
                                   
        
    }else{
        
    }
    
    
}
//-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
//    NSLog(@"Error here: .....%@" , error);
//}
@end
