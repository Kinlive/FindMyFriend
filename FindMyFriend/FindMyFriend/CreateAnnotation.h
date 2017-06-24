//
//  CreatAnnotation.h
//  FindMyFriend
//
//  Created by Kinlive on 2017/6/24.
//  Copyright © 2017年 Kinlive Wei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "GetFriend.h"
@interface CreateAnnotation : NSObject
@property (nonatomic,weak) MKMapView *mainMapView;
-(MKPointAnnotation*) createAnnotationWithFriendsInfo:(NSArray<GetFriend*>*)friendsInfo andCountFriends:(int) countFriends;
@end
