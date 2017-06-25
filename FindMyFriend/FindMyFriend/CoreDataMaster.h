//
//  CoreDataMaster.h
//  FindMyFriend
//
//  Created by Kinlive on 2017/6/25.
//  Copyright © 2017年 Kinlive Wei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyLocation+CoreDataClass.h"
#import "AppDelegate.h"
@interface CoreDataMaster : NSObject
{
    MyLocation *myCoreData;
    NSManagedObjectContext *context;
    NSEntityDescription *entity;
}
-(void) initSomething;
-(void) startSaveDataWithLat:(double) latitude andLon:(double) longitude;
-(void) getSaveData;

@end
