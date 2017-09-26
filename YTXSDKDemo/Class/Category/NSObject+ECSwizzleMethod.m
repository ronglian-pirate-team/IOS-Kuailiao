//
//  NSObject+ECSwizzleMethod.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/30.
//
//

#import "NSObject+ECSwizzleMethod.h"
#import <objc/runtime.h>

@implementation NSObject (ECSwizzleMethod)

- (void)ec_swizzleMethod:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector {
    
    Class ec_cls = [self class];
    
    Method ec_originalM = class_getClassMethod(ec_cls, originalSelector);
    IMP ec_originalImp = method_getImplementation(ec_originalM);
    const char *ec_orignalType = method_getTypeEncoding(ec_originalM);
    
    Method ec_swizzleM = class_getClassMethod(ec_cls, swizzledSelector);
    IMP ec_swizzleImp = method_getImplementation(ec_swizzleM);
    const char *ec_swizzleType = method_getTypeEncoding(ec_swizzleM);
    
    BOOL isAddSuccess = class_addMethod(ec_cls, originalSelector, ec_swizzleImp, ec_swizzleType);
    
    if (isAddSuccess) {
        
        class_replaceMethod(ec_cls, swizzledSelector, ec_originalImp, ec_orignalType);
    } else {
        method_exchangeImplementations(ec_originalM, ec_swizzleM);
    }
}

- (BOOL)ec_validObserverKeyPath:(NSString *)key {
    id observInfo = self.observationInfo;
    NSArray *array = [observInfo valueForKey:@"_observances"];
    for (id objc in array) {
        id properts = [objc valueForKeyPath:@"_property"];
        NSString *keyPath = [properts valueForKeyPath:@"_keyPath"];
        if ([key isEqualToString:keyPath]) {
            return YES;
        }
    }
    return NO;
}
@end
