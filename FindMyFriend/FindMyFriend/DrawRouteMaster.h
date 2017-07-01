//
//  DrawRouteMaster.h
//  FindMyFriend
//
//  Created by Kinlive on 2017/6/29.
//  Copyright © 2017年 Kinlive Wei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
@interface DrawRouteMaster : NSObject
-(MKDirectionsRequest*)getCoordinateWith:(CLLocationCoordinate2D)resourceCoor and:(CLLocationCoordinate2D)destinationCoor;
-(MKPolyline*)showUserSportRouteOn:(NSMutableArray<CLLocation*>*)lastLocationsArray ;
@end
