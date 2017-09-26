//
//  ECLiveRoomShow.m
//  ECSDKDemo_OC
//
//  Created by huangjue on 2017/6/26.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "ECLiveRoomShow.h"

@interface ECLiveRoomShow ()
@property (nonatomic, strong) NSArray *giftDataSource;
@property (nonatomic, strong) LiveUserModel *firstUser;
@property (nonatomic, strong) NSMutableArray *giftArr;
@end

@implementation ECLiveRoomShow

+ (instancetype)showView:(UIView *)superView {
    return [[[self alloc] init] showView:superView];
}

- (instancetype)showView:(UIView *)superView {
    _giftShow = [LiveGiftShowCustom addToView:superView];
    [_giftShow setMaxGiftCount:3];
    LiveGiftShowModel *model = [LiveGiftShowModel giftModel:self.giftArr[3] userModel:self.firstUser];
    [_giftShow addLiveGiftShowModel:model];
    return self;
}

- (void)doubleClicked {
    LiveGiftShowModel *model = [LiveGiftShowModel giftModel:self.giftArr[3] userModel:self.firstUser];
    [_giftShow addLiveGiftShowModel:model];
}

- (NSArray *)giftDataSource{
    if (!_giftDataSource) {
        _giftDataSource = @[
                            @{
                                @"name": @"松果",
                                @"rewardMsg": @"扔出一颗松果",
                                @"personSort": @"0",
                                @"goldCount": @"3",
                                @"type": @"0",
                                @"placeImg": @"bangbangtang",
                                },
                            @{
                                @"name": @"花束",
                                @"rewardMsg": @"献上一束花",
                                @"personSort": @"6",
                                @"goldCount": @"66",
                                @"type": @"1",
                                @"placeImg": @"bangbangtang",
                                },
                            @{
                                @"name": @"果汁",
                                @"rewardMsg": @"递上果汁",
                                @"personSort": @"3",
                                @"goldCount": @"18",
                                @"type": @"2",
                                @"placeImg": @"bangbangtang",
                                },
                            @{
                                @"name": @"棒棒糖",
                                @"rewardMsg": @"递上棒棒糖",
                                @"personSort": @"2",
                                @"goldCount": @"8",
                                @"type": @"3",
                                @"placeImg": @"bangbangtang",
                                },
                            @{
                                @"name": @"泡泡糖",
                                @"rewardMsg": @"一起吃泡泡糖吧",
                                @"personSort": @"2",
                                @"goldCount": @"8",
                                @"type": @"4",
                                @"placeImg": @"bangbangtang",
                                },
                            ];
    }
    return _giftDataSource;
}

- (LiveUserModel *)firstUser {
    if (!_firstUser) {
        _firstUser = [[LiveUserModel alloc]init];
        _firstUser.name = @"first";
        _firstUser.iconUrl = @"http://ww1.sinaimg.cn/large/c6a1cfeagy1ffbg8tb6wqj20gl0qogni.jpg";
    }
    return _firstUser;
}

- (NSMutableArray *)giftArr {
    if (!_giftArr) {
        _giftArr = [NSMutableArray array];
        for (NSDictionary *dict in self.giftDataSource) {
            LiveGiftListModel *model = [[LiveGiftListModel alloc] init];
            [model setValuesForKeysWithDictionary:dict];
            [_giftArr addObject:model];
        }
    }
    return _giftArr;
}
@end
