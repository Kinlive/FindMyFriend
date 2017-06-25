//
//  MyLocation+CoreDataProperties.h
//  
//
//  Created by Kinlive on 2017/6/25.
//
//

#import "MyLocation+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface MyLocation (CoreDataProperties)

+ (NSFetchRequest<MyLocation *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *dateTime;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

@end

NS_ASSUME_NONNULL_END
