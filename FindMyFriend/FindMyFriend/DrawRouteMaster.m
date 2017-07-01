//
//  DrawRouteMaster.m
//  FindMyFriend
//
//  Created by Kinlive on 2017/6/29.
//  Copyright © 2017年 Kinlive Wei. All rights reserved.
//

#import "DrawRouteMaster.h"

@implementation DrawRouteMaster
-(MKDirectionsRequest*)getCoordinateWith:(CLLocationCoordinate2D)resourceCoor and:(CLLocationCoordinate2D)destinationCoor{
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
//    MKDirections *direction = [[MKDirections alloc] initWithRequest:dirRequest];
    return dirRequest;
}
-(MKPolyline *)showUserSportRouteOn:(NSMutableArray<CLLocation *> *)lastLocationsArray{
    CLLocationCoordinate2D userCoordinates[lastLocationsArray.count];
    int i = 0;
    //get user's coordinates in for drawpolyline method use
    for (CLLocation *location in lastLocationsArray ){
        userCoordinates[i] = location.coordinate;
        i++;
    }
    //將每一個uesr自己的coordinate加入到 coordinates 陣列內
    MKPolyline *selfPolyline = [MKPolyline polylineWithCoordinates:userCoordinates count:lastLocationsArray.count];
    return  selfPolyline;
}
@end
