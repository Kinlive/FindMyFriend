//
//  RequestMaster.m
//  FindMyFriend
//
//  Created by Kinlive on 2017/6/24.
//  Copyright © 2017年 Kinlive Wei. All rights reserved.
//

#import "RequestMaster.h"

@implementation RequestMaster

-(void) startRequestServerWithCoordinateLat:(NSString*) lat andLon:(NSString*) lon{
    //AFNetworking 基本使用流程
    DXHTTPManager *manager = [DXHTTPManager manager];
    NSString *url = UPLOADURL_TAG;
    NSString *parameters = [NSString stringWithFormat:@"GroupName=%@&UserName=%@&Lat=%@&Lon=%@",GROUPNAME_TAG,USERNAME_TAG,lat,lon];
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
}
-(NSArray<GetFriend*>*) startGetFriendsInfo{
    NSMutableArray<GetFriend*> *getFriendArray = [NSMutableArray new]  ;
//    infoResult = [NSArray new];
    DXHTTPManager *manager = [DXHTTPManager manager];
    NSString *url = GETINFOURL_TAG;
      [manager GET:url parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        //..
//        NSLog(@"回報中.....%@", url);
        NSLog(@"Server response:%@", responseObject);
        //此處因為AFNetworking 的manager 已經有自動將responseObject進行JSON轉換為dictionary,因此可以如下方直接以key的方式呼叫出整個陣列;
        NSArray *friendArray = responseObject[KEY_TAG];
        for (int i =0 ; i< friendArray.count; i++) {
            GetFriend *getFriend = [GetFriend new];
            getFriend.name = friendArray[i][NAME_TAG];
            getFriend.dateTime = friendArray[i][DATETIME_TAG];
            getFriend.lat = [friendArray[i][LAT_TAG] doubleValue];
            getFriend.lon = [friendArray[i][LON_TAG] doubleValue];
//            NSLog(@"第%d筆朋友: %@ , %@, %lf , %lf", i+1 , getFriend.name, getFriend.dateTime,getFriend.lat,getFriend.lon);
            //測試有沒有正確拿到 OK
            //正確取得朋友資料並加入陣列,待標示出朋友位置使用
            [getFriendArray addObject:getFriend];
//           NSLog(@"TITLE有沒有拿到4:%@" , getFriendArray[i].name);
            //確定拿到ＯＫ
        }//for 迴圈到此
        ///結果丟給infoResult
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        //..
        NSLog(@"回報失敗....");
        NSLog(@"Error: %@  ", error);
    }];
    return getFriendArray;
}// 方法結束

-(NSArray<GetFriend*>*)getInfoResult{
    NSLog(@"TITLE有沒有拿到2:%@" , infoResult[0].name);
    return infoResult;
}

@end
