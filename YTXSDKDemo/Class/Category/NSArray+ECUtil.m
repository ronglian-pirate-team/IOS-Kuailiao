//
//  NSArray+ECUtil.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/30.
//
//

#import "NSArray+ECUtil.h"
#import <objc/runtime.h>

@implementation NSArray (ECUtil)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            
            [objc_getClass("__NSArrayI") ec_swizzleMethod:@selector(objectAtIndex:) swizzledSelector:@selector(objectAtIndexCheck:)];
            [objc_getClass("__NSArrayM") ec_swizzleMethod:@selector(objectAtIndex:) swizzledSelector:@selector(objectAtIndexCheck:)];
        }
    });
}

- (id)objectAtIndexCheck:(NSUInteger)index {
    
    if (index >= self.count)
        return nil;
    id value = [self objectAtIndex:index];
    if (value == [NSNull null]) {
        return nil;
    }
    return value;
}
@end


@implementation NSMutableArray (ECUtil)

- (id)objectAtIndexCheck:(NSUInteger)index {
    
    if (index >= self.count)
        return nil;
    id value = [self objectAtIndex:index];
    if (value == [NSNull null]) {
        return nil;
    }
    return value;
}

@end
