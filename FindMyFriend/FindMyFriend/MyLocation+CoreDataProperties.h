//
//  MyLocation+CoreDataProperties.h
//  FindMyFriend
//
//  Created by Kinlive on 2017/6/25.
//  Copyright © 2017年 Kinlive Wei. All rights reserved.
//

#import "MyLocation+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface MyLocation (CoreDataProperties)

+ (NSFetchRequest<MyLocation *> *)fetchRequest;

@property (nonatomic) double lontitude;
@property (nonatomic) double latitude;

@end

NS_ASSUME_NONNULL_END
