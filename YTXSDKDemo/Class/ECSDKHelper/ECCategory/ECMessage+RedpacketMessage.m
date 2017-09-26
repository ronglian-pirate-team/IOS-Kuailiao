//
//  ECMessage+RedpacketMessage.m
//  ECSDKDemo_OC
//
//  Created by huangjue on 16/7/25.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "ECMessage+RedpacketMessage.h"
#import <objc/runtime.h>
#import "RedpacketViewControl.h"

const char kRpmessage;

@implementation ECMessage(RedPacketMessage)

- (void)setRpModel:(RedpacketMessageModel *)rpModel{
    [self willChangeValueForKey:@"rpModel"];
    objc_setAssociatedObject(self,&kRpmessage, rpModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"rpModel"];
}

- (RedpacketMessageModel *)rpModel{
    RedpacketMessageModel *model = objc_getAssociatedObject(self, &kRpmessage);
    return model;
}

- (BOOL)isRedpacket{
    if (self.rpModel) {
        return YES;
    }
    if (self.userData) {
        NSDictionary * dict = [self redPacketDic];
        if (dict && [RedpacketMessageModel isRedpacketRelatedMessage:dict]) {
            RedpacketMessageModel * redpacketModel = [RedpacketMessageModel redpacketMessageModelWithDic:dict];
            self.rpModel = redpacketModel;
            return YES;
        }
    }
    return NO;
}

- (RedpacketMessageModel*)getRpmodel:(NSString*)userdata {
    if (self.userData) {
        NSDictionary * dict = [self redPacketDic];
        if (dict && [RedpacketMessageModel isRedpacketRelatedMessage:dict]) {
            RedpacketMessageModel * redpacketModel = [RedpacketMessageModel redpacketMessageModelWithDic:dict];
            self.rpModel = redpacketModel;
        }
    }
    return self.rpModel;
}

- (BOOL)isRedpacketOpenMessage
{
    if (self.userData) {
        NSDictionary * dict = [self redPacketDic];
        return  ![RedpacketMessageModel isRedpacket:dict];
    }
    return NO;
}

- (NSString *)redpacketString
{
    if (!self.rpModel) {
        return @"";
    }
    
    if (RedpacketMessageTypeRedpacket == self.rpModel.messageType) {
        
        return [NSString stringWithFormat:@"[%@]%@", self.rpModel.redpacket.redpacketOrgName, self.rpModel.redpacket.redpacketGreeting];
        
    } else if (RedpacketMessageTypeTedpacketTakenMessage == self.rpModel.messageType) {
        
        NSString *s = nil;
        if (self.isGroup) {
            
            if([self.rpModel.redpacketSender.userId isEqualToString:self.rpModel.redpacketReceiver.userId]) {
                s = @"你领取了自己的红包";
            } else if (self.rpModel.isRedacketSender) {
                s = [NSString stringWithFormat:@"%@领取了你的红包",self.rpModel.redpacketReceiver.userNickname];
            } else if (![self.rpModel.currentUser.userId isEqualToString:self.rpModel.redpacketReceiver.userId]) {
                s = [NSString stringWithFormat:@"%@领取了%@的红包",self.rpModel.redpacketReceiver.userNickname,self.rpModel.redpacketSender.userNickname];
            } else {
                s = [NSString stringWithFormat:@"你领取了%@的红包",self.rpModel.redpacketSender.userNickname];
            }
            
        } else {
            
            if ([self.rpModel.currentUser.userId isEqualToString:self.rpModel.redpacketSender.userId]) {
                s = [NSString stringWithFormat:@"%@领取了你的红包",self.rpModel.redpacketReceiver.userNickname];
            } else {
                s = [NSString stringWithFormat:@"你领取了%@的红包",self.rpModel.redpacketSender.userNickname];
            }
        }
        return s;
        
    }
    return @"";
}

- (NSDictionary *)redPacketDic
{
    NSData *data = [self.userData dataUsingEncoding:NSUTF8StringEncoding];
    if (data.length < 1) {
        return nil;
    }
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    return dict;
}

+ (NSString *)voluationModele:(RedpacketMessageModel *)model
{
    NSString * rpString = nil;
    objc_setAssociatedObject(self,&kRpmessage, model, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    NSDictionary * rp = [model.redpacketMessageModelToDic mutableCopy];
    if (rp){
        NSError * error;
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:rp options:NSJSONWritingPrettyPrinted error:&error];
        if (!error) {
            rpString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
    }
    [self didChangeValueForKey:@"rpModel"];
    
    return rpString;
}

@end
