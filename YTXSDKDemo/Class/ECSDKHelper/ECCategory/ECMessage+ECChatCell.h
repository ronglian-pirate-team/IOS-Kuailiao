//
//  ECMessage+ECHeight.h
//  YTXSDKDemo
//
//  Created by xt on 2017/8/1.
//
//

#import "ECMessage.h"

@interface ECMessage (ECChatCell)

@property (nonatomic, assign) CGFloat cellWidth;
@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, strong) UIImage *shotImg;
@property (nonatomic, assign) BOOL isReadFireMessage;

@property (nonatomic, assign) NSInteger readCount;
@end
