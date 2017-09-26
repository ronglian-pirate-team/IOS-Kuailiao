//
//  ECGroupSettingTopVC.m
//  YTXSDKDemo
//
//  Created by xt on 2017/7/28.
//
//

#import "ECGroupSettingTopVC.h"
#import "ECGroupMemberCell.h"
#import "ECAddFriendVC.h"
#import "ECMainTabbarVC.h"
#import "ECDemoGroupManage.h"

#define ec_max_cellnum 98
#define ec_line_num 6

#define ec_cell_headerV 45.0f
#define EC_LINE_SPACE 14
#define EC_VER_SPACE 10.0
#define EC_CELL_SIZE (EC_kScreenW - (ec_line_num + 1) * EC_LINE_SPACE) / ec_line_num

@interface ECGroupSettingTopVC ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) ECGroup *group;
@property (nonatomic, assign) ECMemberRole role;
@property (nonatomic, strong) NSMutableArray *memberArr;
@end

@implementation ECGroupSettingTopVC
{
    NSInteger _memberCount;
}

- (void)InviteMember{
    ECAddFriendVC *friendVC = [[ECAddFriendVC alloc] init];
    friendVC.isEditing = 2;
    friendVC.groupId = self.group.groupId;
    friendVC.isDiscuss = self.group.isDiscuss;
    [[AppDelegate sharedInstanced].rootNav pushViewController:friendVC animated:YES];
}

- (void)tapAction{
    [[AppDelegate sharedInstanced].rootNav ec_pushViewController:[[NSClassFromString(@"ECGroupMemberListSetVC") alloc] init] animated:YES data:@(0)];
}

- (void)deleteMember{
    UIViewController *deleteVC = [[NSClassFromString(@"ECGroupMemberOperationVC") alloc] init];
    [[AppDelegate sharedInstanced].rootNav ec_pushViewController:deleteVC animated:YES data:@(1)];
}

#pragma mark - UICollectionView delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger sumcount = (self.group.memberCount>0 && self.memberArr.count==0)?_memberCount:self.memberArr.count;
    if(indexPath.row >= sumcount){
        if(indexPath.row - sumcount == 0){
            [self InviteMember];
        }else if (indexPath.row - sumcount == 1){
            [self deleteMember];
        }
    } else if (self.memberArr.count) {
        ECGroupMember *member = self.memberArr[indexPath.row];
        [[AppDelegate sharedInstanced].rootNav ec_pushViewController:[[NSClassFromString(@"ECFriendInfoDetailVC") alloc] init] animated:YES data:member.memberId];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ECGroupMemberCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ECGroupMember_Cell" forIndexPath:indexPath];
    if(indexPath.row >= ((self.group.memberCount>0 && self.memberArr.count==0)?_memberCount:self.memberArr.count)){
        cell.imageName = (indexPath.row - _memberArr.count ? @"qunzusettingIconDelete" : @"qunzusettingIconAdd");
        return cell;
    }
    if ((self.group.memberCount>0 && self.memberArr.count==0)) {
        [cell defaultCell];
    } else {
        ECGroupMember *member = self.memberArr[indexPath.row];
        cell.groupMember = member;
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if(kind == UICollectionElementKindSectionHeader){
        UICollectionReusableView *reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"ECCollectionHeader" forIndexPath:indexPath];

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, EC_kScreenW - 24, ec_cell_headerV)];
        label.text = NSLocalizedString(@"群成员", nil);
        label.font = EC_Font_System(16);
        [reusableView addSubview:label];
        reusableView.backgroundColor = EC_Color_White;
        return reusableView;
    } else if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"ECCollectionFooter" forIndexPath:indexPath];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, EC_kScreenW - 24, ec_cell_headerV)];
        label.text = NSLocalizedString(@"查看成员列表", nil);
        label.font = EC_Font_System(16);
        label.userInteractionEnabled = YES;
        [footer addSubview:label];
        UIImageView *imgV = [[UIImageView alloc] initWithImage:EC_Image_Named(@"workbenchIconGo")];
        imgV.frame = CGRectMake(label.ec_width - 8.0f, (label.ec_height - 15.0f) / 2, 8.0f, 15.0f);
        imgV.userInteractionEnabled = YES;
        [label addSubview:imgV];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [label addGestureRecognizer:tap];
        footer.backgroundColor = EC_Color_White;
        return footer;
    }
    return nil;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSInteger count = ((self.group.memberCount>0 && self.memberArr.count==0)?_memberCount:self.memberArr.count) + ([ECDemoGroupManage sharedInstanced].group.selfRole == ECMemberRole_Creator || [ECDemoGroupManage sharedInstanced].group.selfRole == ECMemberRole_Admin ? 2 : 0);
    return count;
}

#pragma mark - 创建UI
- (instancetype)init {
    self = [super init];
    if (self) {
        NSInteger count = [ECDemoGroupManage sharedInstanced].group.memberCount + ([ECDemoGroupManage sharedInstanced].group.selfRole == ECMemberRole_Creator || self.group.selfRole == ECMemberRole_Admin ? 2 : 0);
        _memberCount = count <= ec_max_cellnum?count:ec_max_cellnum;
        count = count <= 0?1:count;
        NSInteger num = _memberCount / ec_line_num;
        if (_memberCount % ec_line_num != 0)
            num += 1;
        NSInteger sumspace = EC_LINE_SPACE * (num - 1);
        CGFloat itemH = ec_cell_headerV * 2 + num * EC_CELL_SIZE;
        CGFloat ec_view_h = itemH + sumspace;
        self.view.frame = CGRectMake(0, 0, EC_kScreenW, ec_view_h);
        self.collectionView.frame = CGRectMake(0, 0, EC_kScreenW, ec_view_h);
    }
    return self;
}

- (void)buildUI{
    self.view.backgroundColor = EC_Color_White;
    self.group = [ECDemoGroupManage sharedInstanced].group;
    [self.view addSubview:self.collectionView];
    [super buildUI];
}

- (void)ec_addNotify {
    [self fetchModel];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchModel) name:EC_DEMO_KNotice_ReloadGroupMember object:nil];
}

- (void)fetchModel {
    EC_WS(self);
    [weakSelf.memberArr removeAllObjects];
    [ECDemoGroupManage sharedInstanced].members = [[[ECDBManager sharedInstanced].groupMemberMgr queryMembers:self.group.groupId] mutableCopy];
    [[ECDemoGroupManage sharedInstanced].members enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx < _memberCount) {
            [weakSelf.memberArr addObject:obj];
        }
    }];
    [self.collectionView reloadData];
}
#pragma mark - 懒加载
- (UICollectionView *)collectionView{
    if(!_collectionView){
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = EC_LINE_SPACE;
        layout.minimumLineSpacing = EC_LINE_SPACE;
        layout.itemSize = CGSizeMake(EC_CELL_SIZE, EC_CELL_SIZE);
        layout.headerReferenceSize = CGSizeMake(EC_kScreenW, ec_cell_headerV);
        layout.footerReferenceSize = CGSizeMake(EC_kScreenW, ec_cell_headerV);
        layout.sectionInset = UIEdgeInsetsMake(0, EC_LINE_SPACE, 0, EC_LINE_SPACE);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, EC_kScreenW, 100) collectionViewLayout:layout];
        _collectionView.backgroundColor = EC_Color_White;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.scrollEnabled = NO;
        [_collectionView registerClass:[ECGroupMemberCell class] forCellWithReuseIdentifier:@"ECGroupMember_Cell"];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ECCollectionHeader"];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"ECCollectionFooter"];
    }
    return _collectionView;
}

- (NSMutableArray *)memberArr {
    if (!_memberArr) {
        _memberArr = [NSMutableArray array];
    }
    return _memberArr;
}
@end
