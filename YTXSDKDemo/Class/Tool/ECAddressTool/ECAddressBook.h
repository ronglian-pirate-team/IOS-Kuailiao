//
//  ECAddressBook.h
//  YTXSDKDemo
//
//  Created by xt on 2017/7/26.
//
//

#import <Foundation/Foundation.h>

@interface ECAddressBook : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSArray *phones;
@property (nonatomic, strong) NSNumber *index;

@property (nonatomic, copy) NSString *firstLetter;

@property (nonatomic, assign) BOOL isAdded;

@property (nonatomic, copy) NSString *avatar;

@end
