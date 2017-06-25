//
//  MyLocation+CoreDataProperties.m
//  
//
//  Created by Kinlive on 2017/6/25.
//
//

#import "MyLocation+CoreDataProperties.h"

@implementation MyLocation (CoreDataProperties)

+ (NSFetchRequest<MyLocation *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"MyLocation"];
}

@dynamic dateTime;
@dynamic latitude;
@dynamic longitude;

@end
