//
//  ECLocationPoint.m
//  ECSDKDemo_OC
//
//  Created by admin on 15/12/15.
//  Copyright © 2015年 ronglian. All rights reserved.
//

#import "ECLocationPoint.h"
#import <MapKit/MapKit.h>

@implementation ECLocationPoint

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate andTitle:(NSString *)title{
    self = [super init];
    if (self) {
        _coordinate = coordinate;
        _title      = title;
    }
    return self;
}

@end
