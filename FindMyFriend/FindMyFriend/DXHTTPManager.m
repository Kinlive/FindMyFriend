//
//  DXHTTPManager.m
//  FindMyFriend
//
//  Created by Kinlive on 2017/6/22.
//  Copyright © 2017年 Kinlive Wei. All rights reserved.
//

#import "DXHTTPManager.h"

@implementation DXHTTPManager
//instancetype 可以辨識回傳型別的關鍵字
//建立類別,並且改寫父類別建構子
+ (instancetype)manager {
    //[super manager] 父類別呼叫建構子
    DXHTTPManager *dxManager = [super manager];
    // 可變集合,繼承自NSSet的[ set] Creates and returns an empty set.
    NSMutableSet *newSet = [NSMutableSet set];
    //先將原本可接受的類別丟進newSet內
    newSet.set = dxManager.responseSerializer.acceptableContentTypes;
    //對於server序列化的回應,我們的manager需要可翻譯text/html的類型
    [newSet addObject:@"text/html"];
    //將原本可接受的類型的內容進行改寫承我們自定義的
    dxManager.responseSerializer.acceptableContentTypes = newSet;
    
    return dxManager;
}


@end
