//
//  ECMeetingMemberView.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/17.
//
//

#import "ECMeetingMemberView.h"
#import "ECVoiceMeetingMemberCell.h"
#import "ECMainTabbarVC.h"
#import "ECMeetingInviteVC.h"
#import "ECDemoMetttingManage.h"

#define EC_DEMO_kNotification_RequestVideo @"EC_DEMO_kNotification_RequestVideo"
#define EC_Operatin_Num 2

@interface ECMeetingMemberView()<UICollectionViewDelegate, UICollectionViewDataSource, UIActionSheetDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSIndexPath *selectIndex;
@property (nonatomic, assign) BOOL isAllMute;//是否全员静音

@end

@implementation ECMeetingMemberView
- (instancetype)initWithFrame:(CGRect)frame{
    UICollectionViewFlowLayout *curLayout = [[UICollectionViewFlowLayout alloc] init];
    curLayout.minimumLineSpacing = 30;
    curLayout.itemSize = CGSizeMake(60, 90);
    curLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    curLayout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 12);
    if(self = [super initWithFrame:frame collectionViewLayout:curLayout]){
        self.collectionSource = [NSMutableArray array];
        self.backgroundColor = EC_Color_Tabbar;
        self.delegate = self;
        self.dataSource = self;
        [self registerClass:[ECVoiceMeetingMemberCell class] forCellWithReuseIdentifier:@"ECVoiceMeetingMember_Cell"];
    }
    return self;
}

- (void)setCollectionSource:(NSMutableArray *)collectionSource{
    _collectionSource = collectionSource;
    [self reloadData];
}

- (void)changeStatus:(NSString *)status onMember:(ECMeetingMember *)member {
    BOOL isVideo = [member isKindOfClass:[ECMultiVideoMeetingMember class]];
    if(isVideo){
        ((ECMultiVideoMeetingMember *)member).speakListen = status;
    }else{
        ((ECMultiVoiceMeetingMember *)member).speakListen = status;
    }
    [self.collectionSource replaceObjectAtIndex:self.selectIndex.row - EC_Operatin_Num withObject:member];
    [self reloadItemsAtIndexPaths:@[self.selectIndex]];
}

#pragma mark - UIActionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(actionSheet.tag == 123456){
        ECMeetingMember *selectMember = self.collectionSource[self.selectIndex.row - (self.isCreater ? EC_Operatin_Num : 0)];
        ECVoiceMeetingMemberCell *cell = (ECVoiceMeetingMemberCell *)[self cellForItemAtIndexPath:self.selectIndex];
        BOOL isVideo = [selectMember isKindOfClass:[ECMultiVideoMeetingMember class]];
        ECMeetingType type = isVideo ? ECMeetingType_MultiVideo : ECMeetingType_MultiVoice;
        ECVoIPAccount *account;
        NSString *speakListen;
        if(isVideo){
            account = ((ECMultiVideoMeetingMember *)selectMember).voipAccount;
            speakListen = ((ECMultiVideoMeetingMember *)selectMember).speakListen;
        }else{
            account = ((ECMultiVoiceMeetingMember *)selectMember).account;
            speakListen = ((ECMultiVoiceMeetingMember *)selectMember).speakListen;
        }
        NSMutableString *currentStr = [speakListen mutableCopy];
        if(buttonIndex == 0 && isVideo){
            //发布/取消发布视频
            if(((ECMultiVideoMeetingMember *)selectMember).videoState == 1){
                if([account.account isEqualToString:[ECAppInfo sharedInstanced].persionInfo.userName]){//取消发布视频
                    [[ECDevice sharedInstance].meetingManager cancelPublishSelfVideoFrameInVideoMeeting:self.meetingRoomNum completion:^(ECError *error, NSString *meetingNumber) {
                        ((ECMultiVideoMeetingMember *)selectMember).videoState = 2;
                        cell.videoMember = ((ECMultiVideoMeetingMember *)selectMember);
                        [self.collectionSource replaceObjectAtIndex:self.selectIndex.row - (self.isCreater ? EC_Operatin_Num : 0) withObject:selectMember];
                    }];
                }else{//取消视频
                    ((ECMultiVideoMeetingMember *)selectMember).videoState = 2;
                    cell.videoMember = ((ECMultiVideoMeetingMember *)selectMember);
                    [self.collectionSource replaceObjectAtIndex:self.selectIndex.row - (self.isCreater ? EC_Operatin_Num : 0) withObject:selectMember];
                    [[ECDevice sharedInstance].meetingManager cancelMemberVideoWithAccount:account.account andVideoMeeting:self.meetingRoomNum andPwd:@"" completion:^(ECError *error, NSString *meetingNumber, NSString *member) {
                   }];
                }
            }else{
                if([account.account isEqualToString:[ECAppInfo sharedInstanced].persionInfo.userName]){//发布视频
                    [[ECDevice sharedInstance].meetingManager publishSelfVideoFrameInVideoMeeting:self.meetingRoomNum completion:^(ECError *error, NSString *meetingNumber) {
                        ((ECMultiVideoMeetingMember *)selectMember).videoState = 1;
                        cell.videoMember = ((ECMultiVideoMeetingMember *)selectMember);
                        [self.collectionSource replaceObjectAtIndex:self.selectIndex.row - (self.isCreater ? EC_Operatin_Num : 0) withObject:selectMember];
                    }];
                }else{//请求视频
                    [[NSNotificationCenter defaultCenter] postNotificationName:EC_DEMO_kNotification_RequestVideo object:account.account];
                    ((ECMultiVideoMeetingMember *)selectMember).videoState = 1;
                    cell.videoMember = ((ECMultiVideoMeetingMember *)selectMember);
                    [self.collectionSource replaceObjectAtIndex:self.selectIndex.row - (self.isCreater ? EC_Operatin_Num : 0) withObject:selectMember];
                }
            }
        }else if((buttonIndex == 0 && !isVideo) || (buttonIndex == 1 && isVideo)){//设置禁言
            [[ECDevice sharedInstance].meetingManager setMember:account speakListen:1 ofMeetingType:type andMeetingNumber:self.meetingRoomNum completion:nil];
            [currentStr replaceCharactersInRange:NSMakeRange(1, 1) withString:@"0"];
        }else if((buttonIndex == 1 && !isVideo) || (buttonIndex == 2 && isVideo)){//取消禁言
            [[ECDevice sharedInstance].meetingManager setMember:account speakListen:2 ofMeetingType:type andMeetingNumber:self.meetingRoomNum completion:nil];
            [currentStr replaceCharactersInRange:NSMakeRange(1, 1) withString:@"1"];
        }else if((buttonIndex == 2 && !isVideo) || (buttonIndex == 3 && isVideo)){//设置禁听
            [[ECDevice sharedInstance].meetingManager setMember:account speakListen:3 ofMeetingType:type andMeetingNumber:self.meetingRoomNum completion:nil];
//            [currentStr replaceCharactersInRange:NSMakeRange(0, 1) withString:@"0"];
            currentStr = [@"00" mutableCopy];
        }else if((buttonIndex == 3 && !isVideo) || (buttonIndex == 4 && isVideo)){//取消禁听
            [[ECDevice sharedInstance].meetingManager setMember:account speakListen:4 ofMeetingType:type andMeetingNumber:self.meetingRoomNum completion:nil];
//            [currentStr replaceCharactersInRange:NSMakeRange(0, 1) withString:@"1"];
            currentStr = [@"11" mutableCopy];
        }
        [self changeStatus:currentStr onMember:selectMember];
        return;
    }
    if(buttonIndex == 0 || buttonIndex == 1){
        ECMeetingInviteVC *inviteVC = [[ECMeetingInviteVC alloc] init];
        inviteVC.inviteType = buttonIndex+1;
        inviteVC.meetingNum = self.meetingRoomNum;
        inviteVC.meetingName = self.meetingRoomName;
        inviteVC.inviteCompletion = ^{self.superview.hidden = NO;};
        [[AppDelegate sharedInstanced].rootNav pushViewController:inviteVC animated:YES];
        self.superview.hidden = YES;
    }
}

#pragma mark - UICollection View delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(!self.isCreater)
        return;
    if(indexPath.row == 0){
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"邀请人员", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Voip邀请", nil), NSLocalizedString(@"手机号邀请", nil), nil];
        [actionSheet showInView:self.superview];
    }else if (indexPath.row == 1){
        UIViewController *deleteVC = [[NSClassFromString(@"ECDeleteMeetingMemberVC") alloc] initWithBaeOneObjectCompletion:^(id data) {
            self.superview.hidden = NO;
        } nothingTitle:@"暂无成员"];
        NSMutableArray *array = [[ECDemoMetttingManage sharedInstanced] deleteSelfOfMeeting:self.collectionSource];
        [[AppDelegate sharedInstanced].rootNav ec_pushViewController:deleteVC animated:YES data:@{@"baseDataArray":array,@"meetingNum":self.meetingRoomNum,@"meetingType":@(self.meetingType)}];
        self.superview.hidden = YES;
    }
//    else if (indexPath.row == 2){
//        self.isAllMute = !self.isAllMute;
//        for (ECMultiVoiceMeetingMember *m in self.collectionSource) {
//            ECVoIPAccount *account;
//            if([m isKindOfClass:[ECMultiVideoMeetingMember class]])
//                account = ((ECMultiVideoMeetingMember *)m).voipAccount;
//            if([m isKindOfClass:[ECMultiVoiceMeetingMember class]])
//                account = m.account;
//            NSInteger speak = self.isAllMute ? 1 : 2;
//            [[ECDevice sharedInstance].meetingManager setMember:account speakListen:speak ofMeetingType:self.meetingType andMeetingNumber:self.meetingRoomNum completion:^(ECError *error, NSString *meetingNumber) {
//                if(error.errorCode == ECErrorType_NoError){
//                    EC_Demo_AppLog(@"设置静音成功");
//                }else{
//                    EC_Demo_AppLog(@"设置静音失败");
//                }
//            }];
//        }
//    }
    else{
        self.selectIndex = indexPath;
        ECMeetingMember *member = self.collectionSource[indexPath.row - (self.isCreater ? EC_Operatin_Num : 0)];
        NSString *title = @"";
        UIActionSheet *actionSheet;
        if([member isKindOfClass:[ECMultiVideoMeetingMember class]]){
            title = ((ECMultiVideoMeetingMember *)member).voipAccount.account;
            NSString *ope =  @"";
            if(((ECMultiVideoMeetingMember *)member).videoState == 1){
                if([title isEqualToString:[ECAppInfo sharedInstanced].persionInfo.userName]){
                    ope = NSLocalizedString(@"取消发布视频", nil);
                }else{
                    ope = NSLocalizedString(@"取消视频", nil);
                }
            }else{
                if([title isEqualToString:[ECAppInfo sharedInstanced].persionInfo.userName]){
                    ope = NSLocalizedString(@"发布视频", nil);
                }else{
                    ope = NSLocalizedString(@"请求视频", nil);
                }
            }
            actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) destructiveButtonTitle:nil otherButtonTitles:ope, NSLocalizedString(@"设置禁言", nil), NSLocalizedString(@"取消禁言", nil), NSLocalizedString(@"设置禁听", nil), NSLocalizedString(@"取消禁听", nil), nil];
        }else if([member isKindOfClass:[ECMultiVoiceMeetingMember class]]){
            title = ((ECMultiVoiceMeetingMember *)member).account.account;
            actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"设置禁言", nil), NSLocalizedString(@"取消禁言", nil), NSLocalizedString(@"设置禁听", nil), NSLocalizedString(@"取消禁听", nil), nil];
        }
        actionSheet.tag = 123456;
        [actionSheet showInView:self.superview];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ECVoiceMeetingMemberCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ECVoiceMeetingMember_Cell" forIndexPath:indexPath];
    NSArray *operationArr;
    if(self.meetingType == ECMeetingType_MultiVideo){
        operationArr = @[@{@"title":NSLocalizedString(@"邀请成员", nil), @"image":@"videoMeetingadd"}, @{@"title":NSLocalizedString(@"删除成员", nil), @"image":@"videoMeetingDelete"}, @{@"title":NSLocalizedString(@"全员静音", nil), @"image":self.isAllMute ? @"quanyuanjingyingHigh" : @"quanyuanjingyin"}];
    }else if (self.meetingType == ECMeetingType_MultiVoice){
        operationArr = @[@{@"title":NSLocalizedString(@"邀请成员", nil), @"image":@"add"}, @{@"title":NSLocalizedString(@"删除成员", nil), @"image":@"delete"}, @{@"title":NSLocalizedString(@"全员静音", nil), @"image":self.isAllMute ? @"quanyuanjingyingHigh" : @"jingyin"}];
    }
    if(self.isCreater && (indexPath.row < EC_Operatin_Num)){
        cell.operationInfo = operationArr[indexPath.row];
    }else{
        ECMeetingMember *member = self.collectionSource[indexPath.row - (self.isCreater ? EC_Operatin_Num : 0)];
        if(self.meetingType == ECMeetingType_Interphone){
            cell.interphoneMember = (ECInterphoneMeetingMember *)member;
        }else if(self.meetingType == ECMeetingType_MultiVoice){
            cell.voiceMember = (ECMultiVoiceMeetingMember *)member;
        }else if(self.meetingType == ECMeetingType_MultiVideo){
            cell.videoMember = (ECMultiVideoMeetingMember *)member;
        }
    }
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.collectionSource.count + (self.isCreater ? EC_Operatin_Num : 0);
}

@end
