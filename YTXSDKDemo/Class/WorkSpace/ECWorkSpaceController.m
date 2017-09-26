//
//  ECWorkSpaceController.m
//  YTXSDKDemo
//
//  Created by xt on 2017/7/20.
//  Copyright © 2017年 xt. All rights reserved.
//

#import "ECWorkSpaceController.h"
#import "SDCycleScrollView.h"
#import "ECCreateMeetingVC.h"
#import "ECMeetingListVC.h"

@interface ECWorkSpaceController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) SDCycleScrollView *bannerView;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation ECWorkSpaceController

#pragma mark - 系统 delegate
#pragma mark - UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WorkSpace_Cell"];
    NSDictionary *dic = self.dataArray[indexPath.section][indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.imageView.image = EC_Image_Named(dic[@"image"]);
    cell.textLabel.text = dic[@"text"];
    cell.textLabel.font = EC_Font_System(15);
    if(indexPath.row == [self.dataArray[indexPath.section] count] - 1){
        cell.separatorInset =UIEdgeInsetsMake(0,0, 0,  EC_kScreenW);
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIViewController *vc = nil;
    if(indexPath.section == 0){
        vc = [[ECMeetingListVC alloc] init];
        [(ECMeetingListVC *)vc setMeetingType:indexPath.row + 1];
    } else {
        vc = [[NSClassFromString(@"ECLiveChatRoomList") alloc] init];
    }
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, EC_kScreenH, 44)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, EC_kScreenH, 44)];
    titleLabel.font = EC_Font_System(15);
    titleLabel.text = section == 0 ? NSLocalizedString(@"移动办公",nil) : NSLocalizedString(@"其他应用",nil);
    [sectionView addSubview:titleLabel];
    sectionView.backgroundColor = EC_Color_VCbg;
    return sectionView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataArray[section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44.0f;
}

#pragma mark - UI创建
- (void)buildUI{
    UITableView *tableView = [[UITableView alloc] init];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = EC_Color_Clear;
    tableView.sectionHeaderHeight = 44.0;
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"WorkSpace_Cell"];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    SDCycleScrollView *bannerView = [[SDCycleScrollView alloc] initWithFrame:CGRectMake(0, 0, EC_kScreenW, EC_kScreenW * 0.4)];
    bannerView.localizationImageNamesGroup = @[EC_Image_Named(@"workbenchIconBanner")];
    tableView.tableFooterView = [UIView new];
    tableView.tableHeaderView = bannerView;
    self.bannerView = bannerView;
    EC_WS(self);
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.view);
    }];
    self.dataArray = @[
                       @[@{@"image":@"workbenchIconYuyin", @"text":NSLocalizedString(@"语音群聊",nil)}, @{@"image":@"workbenchIconShipin", @"text":NSLocalizedString(@"视频会议",nil)}, @{@"image":@"workbenchIconDuijiang", @"text":NSLocalizedString(@"实时对讲",nil)}],
                       @[@{@"image":@"workbenchIconZhibo", @"text":NSLocalizedString(@"直播",nil)}]];
    [super buildUI];
}

@end
