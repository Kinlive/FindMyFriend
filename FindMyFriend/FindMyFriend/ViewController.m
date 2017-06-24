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
#import "DXHTTPManager.h"
#import "GetFriend.h"
#define GROUPNAME_TAG @"bp102"
#define USERNAME_TAG     @"Kinwe"
@interface ViewController () <CLLocationManagerDelegate,MKMapViewDelegate>{
    CLLocationManager *locationManager;
    CLLocation *lastLocation;
    NSMutableArray *getFriendArray;
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
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MKCoordinateRegion region ;
        region.center = coordinate ;
        region.span = MKCoordinateSpanMake(0.001, 0.001);
        [_mainMapView setRegion:region  animated: true];
    });
}

- (IBAction)openOrCloseReport:(id)sender {
    CLLocationCoordinate2D coordinate = lastLocation.coordinate;
    NSString *strLat = [NSString stringWithFormat:@"%f",coordinate.latitude];
    NSString *strLon = [NSString stringWithFormat:@"%f",coordinate.longitude];
    if(_switchStatus.on){
//        UIAlertController *alert = UIAlertViewStyleDefault;
        //記得加警告視窗詢問user
        //upload.
        //AFNetworking 應用基本流程
        
        DXHTTPManager *manager = [DXHTTPManager manager];
        NSString *url = @"http://class.softarts.cc/FindMyFriends/updateUserLocation.php?";
        NSString *parameters = [NSString stringWithFormat:@"GroupName=%@&UserName=%@&Lat=%@&Lon=%@",GROUPNAME_TAG,USERNAME_TAG,strLat,strLon];
      NSString *urlAddParameters = [url stringByAppendingString:parameters];
        [manager GET:urlAddParameters parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            //..
             NSLog(@"回報中.....%@", url);
            NSLog(@"Server response:%@", responseObject);
        } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            //..
            NSLog(@"回報失敗....");
             NSLog(@"Error: %@  ", error);
        }];
    
//以下貌似出現AFNetworking 經典bug , content type: txt/html ,code:200 ,
//已另外用DXHTTP解決
//        [manager POST:@"http://class.softarts.cc/FindMyFriends/updateUserLocation.php" parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
//            NSLog(@"JSON:%@", responseObject);
//            NSLog(@"回報中.....");
//        } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
//            NSString *myString = [[NSString alloc] initWithData:operation.request.HTTPBody encoding:NSUTF8StringEncoding];
//            NSLog(@"Error: %@  %@", error , myString);
//            NSLog(@"回報失敗....");
//        }];
    }else{
        
        NSLog(@"使用者關閉回報!!");
    }
}
- (IBAction)getMyfriend:(id)sender {
    DXHTTPManager *manager = [DXHTTPManager manager];
    NSString *url = @"http://class.softarts.cc/FindMyFriends/queryFriendLocations.php?GroupName=bp102";
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        //..
        NSLog(@"回報中.....%@", url);
        NSLog(@"Server response:%@", responseObject);
        //此處因為AFNetworking 的manager 已經有自動將responseObject進行JSON轉換為dictionary,因此可以如下方直接以key的方式呼叫出整個陣列;
        NSArray *friendArray = responseObject[@"friends"];
        for (int i =0 ; i< friendArray.count; i++) {
            GetFriend *getFriend = [GetFriend new];
            getFriend.name = friendArray[i][@"friendName"];
            getFriend.dateTime = friendArray[i][@"lastUpdateDateTime"];
            getFriend.lat = [friendArray[i][@"lat"] doubleValue];
            getFriend.lon = [friendArray[i][@"lon"] doubleValue];
//            NSLog(@"第%d筆朋友: %@ , %@, %lf , %lf", i+1 , getFriend.name, getFriend.dateTime,getFriend.lat,getFriend.lon); 測試有沒有正確拿到
            //正確取得朋友資料並加入陣列,待顯示使用
             [getFriendArray addObject:getFriend];
        }
        
        
//        getFriend.name = responseObject[@"friends"][0][@"friendName"];
//        NSLog(@"%@",getFriend.dateTime);
//        NSError *error;
    //        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error ];
        
//        if ([jsonResponse isKindOfClass:[NSDictionary class]]){
//            NSArray *dicArray = jsonResponse[@"friends"];
//            if([dicArray isKindOfClass:[NSArray class]]){
//                for(NSDictionary *dictionary in jsonResponse){
//                    GetFriend *getFriend = [GetFriend new];
//                    getFriend.name = [dictionary objectForKey:@"friendName"];
//                    getFriend.dateTime = [dictionary objectForKey:@"lastUpdateDateTime"];
//                    getFriend.lat = [[dictionary objectForKey:@"lat"] doubleValue];
//                    getFriend.lon = [[dictionary objectForKey:@"lon"] doubleValue];
//                    [getFriendArray addObject:getFriend];
//                }
//            }
//        }
       
        
        
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        //..
        NSLog(@"回報失敗....");
        NSLog(@"Error: %@  ", error);
    }];
    
    
    
    
    
}

//-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
//    NSLog(@"Error here: .....%@" , error);
//}
@end
