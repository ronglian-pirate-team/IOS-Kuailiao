//
//  LiveChatRoomMemberController.m
//  ECSDKDemo_OC
//
//  Created by huangjue on 2017/5/24.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "LiveChatRoomMemberController.h"
#import "LiveChatRoomMemberListCell.h"
#import "LiveChatRoomBaseModel.h"
#import "EdtingLiveChatRoomMember.h"
#import "ECDeviceDelegateHelper+LiveChatRoom.h"

@interface LiveChatRoomMemberController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UIView *adminV;
@property (strong, nonatomic) UIImageView *iconImgV;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UILabel *rooLabel;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *listArray;
@end

@implementation LiveChatRoomMemberController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareUI];
    [[LiveChatRoomBaseModel sharedInstanced] addObserver:self forKeyPath:@"roomInfo" options:NSKeyValueObservingOptionNew |NSKeyValueObservingOptionOld context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCollection:) name:EC_KECNOTIFICATION_LIVECHATROOM_KICKMEMBER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCollection:) name:EC_KECNOTIFICATION_LIVECHATROOM_BLACKMEMBER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCollection:) name:EC_KNOTIFICATION_onReceivedLiveChatRoomNotice object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[ECDevice sharedInstance].liveChatRoomManager queryLiveChatRoomInfo:self.roomId completion:^(ECError *error, ECLiveChatRoomInfo *roomInfo) {
        if (error.errorCode == ECErrorType_NoError) {
            [LiveChatRoomBaseModel sharedInstanced].roomInfo = roomInfo;
        }
    }];
    [self loadList];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)prepareUI {
    [self.view addSubview:self.adminV];
    [self.adminV addSubview:self.iconImgV];
    [self.adminV addSubview:self.rooLabel];
    [self.adminV addSubview:self.label];
    [self.view addSubview:self.collectionView];
    
    __weak typeof(self)weakSelf = self;
    [self.adminV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view).offset(15.0f);
        make.top.equalTo(weakSelf.view).offset(15.0f);
        make.bottom.equalTo(weakSelf.view).offset(-15.0f);
        make.width.offset(140.0f);
    }];
    
    [self.iconImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.adminV).offset(0);
        make.width.and.height.offset(40.0f);
        make.centerY.equalTo(weakSelf.adminV.mas_centerY);
    }];
    
    [self.rooLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.adminV.mas_right).offset(-5.0f);
        make.top.equalTo(weakSelf.adminV.mas_top).offset(10.0f);
        make.left.equalTo(weakSelf.iconImgV.mas_right).offset(3.0f);
        make.height.equalTo(weakSelf.label.mas_height);
    }];

    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.rooLabel.mas_bottom).offset(10.0f);
        make.right.equalTo(weakSelf.adminV.mas_right).offset(-5.0f);
        make.left.equalTo(weakSelf.iconImgV.mas_right).offset(3.0f);
        make.bottom.equalTo(weakSelf.adminV.mas_bottom).offset(-10.0f);
    }];
        
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.and.right.equalTo(weakSelf.view).offset(-10.0f);
        make.top.equalTo(weakSelf.view).offset(10.0f);
        make.left.equalTo(weakSelf.adminV.mas_right).offset(10.0f);
    }];
}

- (void)loadList {
    
    [[ECDevice sharedInstance].liveChatRoomManager queryLiveChatRoomMembers:self.roomId userId:nil pageSize:10 completion:^(ECError *error, NSArray<ECLiveChatRoomMember *> *userArray) {
        if (error.errorCode == ECErrorType_NoError) {
            [self.listArray removeAllObjects];
            [self.listArray addObjectsFromArray:userArray];
            [self.collectionView reloadData];
        }
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"roomInfo"]) {
        _label.text = [NSString stringWithFormat:@"在线:%d",(int)[LiveChatRoomBaseModel sharedInstanced].roomInfo.onlineCount];
    }
}

- (void)refreshCollection:(NSNotification *)noti {
    if ([noti.object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = noti.object;
        ECLiveChatRoomNoticeType type = (ECLiveChatRoomNoticeType)[dict[@"type"] integerValue];
        ECLiveChatRoomMember *member = dict[@"member"];
        if (type == ECLiveChatRoomNoticeType_Join) {
            if ([self.listArray indexOfObject:member] == NSNotFound) {
                [self.listArray addObject:member];
            }
        } else if (type == ECLiveChatRoomNoticeType_Eixt) {
            for (ECLiveChatRoomMember *amember in [self.listArray copy]) {
                if ([amember.useId isEqualToString:member.useId]) {
                    [self.listArray removeObject:amember];
                }
            }
        }
        [self.collectionView reloadData];
    } else {
        ECLiveChatRoomInfo *roomInfo = [LiveChatRoomBaseModel sharedInstanced].roomInfo;
        if (roomInfo.onlineCount>1) {
            roomInfo.onlineCount-=1;
        }
        [LiveChatRoomBaseModel sharedInstanced].roomInfo = roomInfo;
        [self loadList];
    }
}
#pragma mark - UICollectionViewDelegate,UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.listArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ECLiveChatRoomMember *member = self.listArray[indexPath.row];
    LiveChatRoomMemberListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"livechatroom_personreused" forIndexPath:indexPath];
    [cell.imgV addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImgV:)]];
    cell.member = member;
    cell.imgV.tag = indexPath.row;
    return cell;
}

#pragma mark - 基本方法
- (void)tapImgV:(UIGestureRecognizer *)gesture {
    UIImageView *imgV = (UIImageView *)gesture.view;
    ECLiveChatRoomMember *member = nil;
    if (imgV.tag>=0) {
        member = self.listArray.count>imgV.tag?self.listArray[imgV.tag]:nil;
    }
    __weak typeof(self)weakSelf = self;
    [[ECDevice sharedInstance].liveChatRoomManager queryLiveChatRoomMember:member.roomId userId:member.useId completion:^(ECError *error, ECLiveChatRoomMember *amember) {
        
        __strong typeof(weakSelf)strongSelf = weakSelf;
        if (error.errorCode == ECErrorType_NoError) {
            if (strongSelf.block) {
                strongSelf.block(amember);
            }
        }
    }];
}

- (void)tapCreatorImgV:(UIGestureRecognizer *)gesture {
    [[ECDevice sharedInstance].liveChatRoomManager queryLiveChatRoomInfo:self.roomId completion:^(ECError *error, ECLiveChatRoomInfo *roomInfo) {
        [LiveChatRoomBaseModel sharedInstanced].roomInfo = roomInfo;
        dispatch_async(dispatch_get_main_queue(), ^{
            LiveChatRoomInfoController *vc = [[LiveChatRoomInfoController alloc] init];
            vc.roomId = self.roomId;
            vc.view.frame = CGRectMake((EC_kScreenW-280)/2.0f, (EC_kScreenH-300)/2.0f,280 , EC_LiveRoom_InfoH);
            if (self.vcBlock) {
                self.vcBlock(vc);
            }
        });
    }];
}
#pragma mark - 懒加载
- (UIView *)adminV {
    if (!_adminV) {
        _adminV = [[UIView alloc] init];
        _adminV.backgroundColor = [UIColor colorWithHex:0x000000 alpha:0.34f];
        _adminV.layer.cornerRadius = 15.0f;
        _adminV.layer.masksToBounds = YES;
        [_adminV addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCreatorImgV:)]];
    }
    return _adminV;
}

- (UIImageView *)iconImgV {
    if (!_iconImgV) {
        _iconImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"def_usericon4"]];
        _iconImgV.layer.cornerRadius = 20.0f;
        _iconImgV.layer.masksToBounds = YES;
    }
    return _iconImgV;
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.textAlignment = NSTextAlignmentLeft;
        _label.font = [UIFont systemFontOfSize:11.0f];
        _label.text = [NSString stringWithFormat:@"在线:%d",(int)[LiveChatRoomBaseModel sharedInstanced].roomInfo.onlineCount];
        _label.textColor = [UIColor whiteColor];
    }
    return _label;
}

- (UILabel *)rooLabel {
    if (!_rooLabel) {
        _rooLabel = [[UILabel alloc] init];
        _rooLabel.textAlignment = NSTextAlignmentLeft;
        _rooLabel.font = [UIFont systemFontOfSize:11.0f];
        _rooLabel.text = [NSString stringWithFormat:@"房间:%@",[LiveChatRoomBaseModel sharedInstanced].roomInfo.roomId];
        _rooLabel.textColor = [UIColor whiteColor];
    }
    return _rooLabel;
}


- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.itemSize = CGSizeMake(40.0f, 40.0f);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerNib:[UINib nibWithNibName:@"LiveChatRoomMemberListCell" bundle:nil] forCellWithReuseIdentifier:@"livechatroom_personreused"];
    }
    return _collectionView;
}

- (NSMutableArray *)listArray {
    if (!_listArray) {
        _listArray = [NSMutableArray array];
    }
    return _listArray;
}

- (void)dealloc {
    [[LiveChatRoomBaseModel sharedInstanced].roomInfo removeObserver:self forKeyPath:@"roomInfo"];
}
@end
