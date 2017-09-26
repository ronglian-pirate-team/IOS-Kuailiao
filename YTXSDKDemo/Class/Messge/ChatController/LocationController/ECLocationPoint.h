//
//  ECLocationPoint.h
//  ECSDKDemo_OC
//
//  Created by admin on 15/12/15.
//  Copyright © 2015年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface ECLocationPoint : NSObject<MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@property (nonatomic, readonly, copy)   NSString *title;

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate andTitle:(NSString*)title;
@end
