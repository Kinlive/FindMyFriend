//
//  CreatAnnotation.m
//  FindMyFriend
//
//  Created by Kinlive on 2017/6/24.
//  Copyright © 2017年 Kinlive Wei. All rights reserved.
//

#import "CreateAnnotation.h"

@implementation CreateAnnotation

-(MKPointAnnotation*)createAnnotationWithFriendsInfo:(NSArray<GetFriend *> *)friendsInfo andCountFriends:(int) countFriends{
        double lat = friendsInfo[countFriends].lat ;
        double lon = friendsInfo[countFriends].lon;
        //Create friends coordinate
        CLLocationCoordinate2D friendCoord = {(lat),(lon)};
        MKPointAnnotation *friendAnno = [MKPointAnnotation new];
        friendAnno.coordinate = friendCoord;
        friendAnno.title = friendsInfo[countFriends].name;
        friendAnno.subtitle = friendsInfo[countFriends].dateTime;
//        NSLog(@"TITLE:有沒有拿到%@",friendAnno.title);
    return friendAnno;
}
@end
