//
//  ECMessage+ECChatCell.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/1.
//
//

#import "ECMessage+ECChatCell.h"
#import <objc/runtime.h>
#import "ECMessage+ECUtil.h"

static const void *cellWidthKey = &cellWidthKey;
static const void *cellHeightKey = &cellHeightKey;
const char ec_chat_message_shotimg;
const char ec_chat_message_readfire;
const char ec_chat_message_readcount;


@implementation ECMessage (ECChatCell)

- (CGFloat)cellWidth {
    NSNumber *cellWidth = objc_getAssociatedObject(self, cellWidthKey);
    return cellWidth.floatValue;
}

- (void)setCellWidth:(CGFloat)cellWidth{
    objc_setAssociatedObject(self, cellWidthKey, @(cellWidth), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)cellHeight {
    NSNumber *cellHeight = objc_getAssociatedObject(self, cellHeightKey);
    return cellHeight.floatValue;
}

- (void)setCellHeight:(CGFloat)cellHeight{
    objc_setAssociatedObject(self, cellHeightKey, @(cellHeight), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setShotImg:(UIImage *)shotImg {
    NSData *data = UIImagePNGRepresentation(shotImg);
    if (self.messageId.length>0) {
        NSString* fileName = [NSString stringWithFormat:@"%@.png_shot", self.messageId];
        NSString* filePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName];
        [data writeToFile:filePath atomically:YES];
    }
    objc_setAssociatedObject(self,&ec_chat_message_shotimg,data , OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)shotImg {
    NSData *data = objc_getAssociatedObject(self, &ec_chat_message_shotimg);
    if (data==nil) {
        NSString *fileName = [NSString stringWithFormat:@"%@.png_shot", self.messageId];
        NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            data = [NSData dataWithContentsOfFile:filePath];
        }
    }
    return [UIImage imageWithData:data];
}

- (void)setIsReadFireMessage:(BOOL)isReadFireMessage {
    objc_setAssociatedObject(self, &ec_chat_message_readfire, @(isReadFireMessage), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(BOOL)isReadFireMessage {
    NSNumber *isReadFireMessage = objc_getAssociatedObject(self, &ec_chat_message_readfire);
    if (!isReadFireMessage)
        isReadFireMessage = @([ECMessage ExtendTypeOfTextMessage:self] == EC_Demo_CAHT_MESSAGE_CUSTOMTYPE_FIREMESSAGE);
    return isReadFireMessage.boolValue;
}

- (void)setReadCount:(NSInteger)readCount {
    objc_setAssociatedObject(self, &ec_chat_message_readcount, @(readCount), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)readCount {
    NSNumber *readCount = objc_getAssociatedObject(self, &ec_chat_message_readcount);
    return readCount.integerValue;
}
@end
