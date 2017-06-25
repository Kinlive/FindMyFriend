//
//  MyLocation+CoreDataProperties.m
//  FindMyFriend
//
//  Created by Kinlive on 2017/6/25.
//  Copyright © 2017年 Kinlive Wei. All rights reserved.
//

#import "MyLocation+CoreDataProperties.h"

@implementation MyLocation (CoreDataProperties)

+ (NSFetchRequest<MyLocation *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"MyLocation"];
}

@dynamic lontitude;
@dynamic latitude;

@end
