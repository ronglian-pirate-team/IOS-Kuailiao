//
//  ECMineVC.m
//  YTXSDKDemo
//
//  Created by xt on 2017/7/24.
//  Copyright © 2017年 xt. All rights reserved.
//

#import "ECMineController.h"
#import "ECMineHeadCell.h"
#import <BQMM/BQMM.h>
#import "RedpacketViewControl.h"
#import "ECFriendManager.h"
#import "ECWebBaseController.h"


#define EC_MineController_Redpackt_Title NSLocalizedString(@"钱包", nil)
#define EC_MineController_BQMM_Title     NSLocalizedString(@"表情", nil)
#define EC_MineController_AboutEC_Title  NSLocalizedString(@"关于我们", nil)
#define EC_MineController_Question_Title NSLocalizedString(@"意见反馈", nil)
#define EC_MineController_Setting_Title  NSLocalizedString(@"设置", nil)


@interface ECMineController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation ECMineController


#pragma mark - UITableViewDataSource和UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ECBaseCellModel *cellModel = self.dataArray[indexPath.section][indexPath.row];
    NSString *text = cellModel.text;
    UIViewController *vc = nil;
    if(indexPath.section == 0){
        vc = [[NSClassFromString(@"ECSelfInfoController") alloc] init];
    } else if ([text isEqualToString:EC_MineController_Redpackt_Title]) {
        RedpacketViewControl *controller = [[RedpacketViewControl alloc] init];
        controller.conversationController = self;
        [controller presentChangeMoneyViewController];
        return;
    } else if ([text isEqualToString:EC_MineController_BQMM_Title]) {
        [[MMEmotionCentre defaultCentre] presentShopViewController];
        return;
    } else if ([text isEqualToString:EC_MineController_AboutEC_Title]) {
        vc = [[NSClassFromString(@"ECAboutController") alloc] init];
    } else if ([text isEqualToString:EC_MineController_Question_Title]) {
        vc = [[NSClassFromString(@"ECAboutController") alloc] init];
        NSString *url = [NSString stringWithFormat:@"%@/%@/IMPlus/Suggestion.shtml?userName=%@",EC_UrlHeader,ECSDK_Key,[ECAppInfo sharedInstanced].userName];
        vc = [[ECWebBaseController alloc] initWithUrlStr:url andType:ECWebBaseController_Type_Link completion:nil];
    } else if ([text isEqualToString:EC_MineController_Setting_Title]) {
        vc = [[NSClassFromString(@"ECSettingController") alloc] init];
    }
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ECBaseCellModel *cellModel = self.dataArray[indexPath.section][indexPath.row];
    
    UITableViewCell *cell = nil;
    if(indexPath.section == 0){
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"MineHead_cell"];
        if (cell==nil) {
            cell = [[ECMineHeadCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MineHead_cell"];
        }
        NSString *placeholderImage = [ECAppInfo sharedInstanced].persionInfo.sex == ECSexType_Male ? @"headerMan" : @"headerWoman";
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[ECAppInfo sharedInstanced].persionInfo.avatar] placeholderImage:EC_Image_Named(placeholderImage)];
        cell.textLabel.text = [ECDevicePersonInfo sharedInstanced].displayName;
        cell.detailTextLabel.text = [ECDevicePersonInfo sharedInstanced].userName;
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Mine_Cell"];
        cell.imageView.image = cellModel.iconImg;
        cell.textLabel.text = cellModel.text;
        cell.detailTextLabel.text = cellModel.detailText;
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.font = EC_Font_System(15.0f);
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataArray[section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.section == 0 ? 86 : 44;
}

#pragma mark - UI创建
- (void)buildUI{
    [self.view addSubview:self.tableView];
    
    NSString *placeholderImage = [ECAppInfo sharedInstanced].persionInfo.sex == ECSexType_Male ? @"headerMan" : @"headerWoman";
    self.dataArray = @[
                       @[[ECBaseCellModel baseModelWithText:[ECAppInfo sharedInstanced].persionInfo.nickName detailText:[ECDevicePersonInfo sharedInstanced].userName img:EC_Image_Named(placeholderImage) modelType:nil]
                         ],
                       @[/*[ECBaseCellModel baseModelWithText:EC_MineController_Redpackt_Title detailText:nil img:EC_Image_Named(@"aboutmeIconQianbao") modelType:nil],*/
                         [ECBaseCellModel baseModelWithText:EC_MineController_BQMM_Title detailText:nil img:EC_Image_Named(@"aboutmeIconBiaoqing") modelType:nil]],
                       @[[ECBaseCellModel baseModelWithText:EC_MineController_AboutEC_Title detailText:nil img:EC_Image_Named(@"aboutmeIconGuanyu") modelType:nil],
                         [ECBaseCellModel baseModelWithText:EC_MineController_Question_Title detailText:nil img:EC_Image_Named(@"aboutmeIconFankui") modelType:nil]],
                       @[[ECBaseCellModel baseModelWithText:EC_MineController_Setting_Title detailText:nil img:EC_Image_Named(@"aboutmeIconSetting") modelType:nil]
                         ]
                       ];

    [super buildUI];
}

- (void)ec_addNotify {
    [[NSNotificationCenter defaultCenter] addObserverForName:EC_DEMO_KNotice_UpdateSelfInfo object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }];
}

#pragma mark - 懒加载
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = EC_Color_Clear;
        _tableView.tableFooterView = [UIView new];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Mine_Cell"];
    }
    return _tableView;
}
@end
