//
//  RequestMaster.h
//  FindMyFriend
//
//  Created by Kinlive on 2017/6/24.
//  Copyright © 2017年 Kinlive Wei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DXHTTPManager.h"
#import "GetFriend.h"
#define UPLOADURL_TAG @"http://class.softarts.cc/FindMyFriends/updateUserLocation.php?"
#define GETINFOURL_TAG @"http://class.softarts.cc/FindMyFriends/queryFriendLocations.php?GroupName=bp102"
#define GROUPNAME_TAG @"bp102"
#define USERNAME_TAG     @"Kinwe"
#define NAME_TAG @"friendName"
#define DATETIME_TAG @"lastUpdateDateTime"
#define LAT_TAG @"lat"
#define LON_TAG @"lon"
#define KEY_TAG @"friends"

@interface RequestMaster : NSObject{
    NSArray *infoResult;
}
-(void) startRequestServerWithCoordinateLat:(NSString*) lat andLon:(NSString*) lon;
-(void) startGetFriendsInfo;
-(NSArray*) getInfoResult;

@end
