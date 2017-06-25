//
//  CoreDataMaster.m
//  FindMyFriend
//
//  Created by Kinlive on 2017/6/25.
//  Copyright © 2017年 Kinlive Wei. All rights reserved.
//

#import "CoreDataMaster.h"

@implementation CoreDataMaster

-(void)initSomething{
    ///=====coredata use
    //1. create context
    context = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).persistentContainer.viewContext;
    //2. create entity
    entity = [NSEntityDescription entityForName:@"MyLocation" inManagedObjectContext:context];
}
-(void) startSaveDataWithLat:(double)latitude andLon:(double)longitude{
  
    //3. When created both of context & entity then get new object
    myCoreData = [NSEntityDescription insertNewObjectForEntityForName:@"MyLocation" inManagedObjectContext:context];
    //core data save
    NSError *error ;
    //4. Object set value(entity property) ..
    myCoreData.latitude = latitude;
    myCoreData.longitude = longitude;
//    myCoreData.dateTime = [NSDate date];
    //5. Context save .
    if (![context save:&error]) {
        NSLog(@"Save Error!!");
    }else{
        NSLog(@"Save Is  OK!!");
    }
}
-(void)getSaveData{
    //6. FetchRequest : it's for get saved data
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    //to get all data in database.
    NSArray *results = [[context executeFetchRequest:request error:&error] copy];
    for(MyLocation *p in results){
        NSLog(@"Here get Data!!!!");
        NSLog(@">>>> Latitude : %lf  , Lontitude : %lf   andData: %@",p.latitude , p.longitude,p.dateTime);
    }
}
@end
