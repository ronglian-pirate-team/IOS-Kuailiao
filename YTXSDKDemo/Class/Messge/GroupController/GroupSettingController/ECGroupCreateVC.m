//
//  ECGroupCreateFirstVC.m
//  YTXSDKDemo
//
//  Created by xt on 2017/7/26.
//
//

#import "ECGroupCreateVC.h"
#import "ECGroupTypeVC.h"
#import "ECAddFriendVC.h"
#import "ECGroupNameCell.h"
#import "ECGroupModeCell.h"
#import "ECGroupDeclaredCell.h"

@interface ECGroupCreateVC ()<UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource,ECBaseContollerDelegate>

@property (nonatomic, assign) BOOL isDiscuss;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSArray *areaArr;
@property (nonatomic, strong) UIPickerView *picker;
@property (nonatomic, assign) NSInteger selectProvince;//选择省份 index
@property (nonatomic, assign) NSInteger selectCity;//选择城市 index
@property (nonatomic, assign) NSInteger type;// 1 省份 2 城市
@property (nonatomic, assign) NSInteger groupType;
@property (nonatomic, copy) NSString *groupDeclared;
@property (nonatomic, assign) ECGroupPermMode groupMode;

@end

@implementation ECGroupCreateVC

#pragma mark - 数据获取/处理
- (void)fetchAreaData{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Provineces" ofType:@"plist"];
    self.areaArr = [[NSArray alloc] initWithContentsOfFile:plistPath];
}

#pragma mark - 类私有方法
- (ECGroupPermMode)groupMode{
    ECGroupModeCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
    return cell.isOpen;
}

#pragma mark - UITableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
    if (indexPath.row == 1){
        self.type = 1;
        _picker.hidden = NO;
        [_picker reloadAllComponents];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        cell.detailTextLabel.text = self.areaArr[0][@"ProvinceName"];
        UITableViewCell *cell2 = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
        NSArray *cityArr = self.areaArr[0][@"cities"];
        NSDictionary *cityDic = cityArr[0];
        cell2.detailTextLabel.text = cityDic[@"CityName"];
        self.selectCity = 0;
        self.selectProvince = 0;
    }else if (indexPath.row == 2){
        self.type = 2;
        _picker.hidden = NO;
        [_picker reloadAllComponents];
        [_picker selectRow:0 inComponent:0 animated:YES];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        NSArray *cityArr = self.areaArr[self.selectProvince][@"cities"];
        NSDictionary *cityDic = cityArr[0];
        cell.detailTextLabel.text = cityDic[@"CityName"];
        self.selectCity = 0;
    }else if (indexPath.row == 3){
        _picker.hidden = YES;
        EC_WS(self)
        UIViewController *vc = [[NSClassFromString(@"ECGroupDeclaredVC") alloc] initWithBaeOneObjectCompletion:^(id data) {
            weakSelf.groupDeclared = data;
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
        [self.navigationController ec_pushViewController:vc animated:YES data:@(NO)];
    }else if (indexPath.row == 4){
        _picker.hidden = YES;
        ECGroupTypeVC *vc = [[ECGroupTypeVC alloc] init];
        vc.selectType = ^(NSInteger index, NSString *type){
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            self.groupType = index;
            cell.detailTextLabel.text =  type;
        };
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 0){
        ECGroupNameCell *cell = [[ECGroupNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GroupName_Cell"];
        cell.isDiscuss = self.isDiscuss;
        return cell;
    }else if (indexPath.row == 3){
        ECGroupDeclaredCell *cell = [[ECGroupDeclaredCell alloc] initDeclared:self.groupDeclared reuseIdentifier:@"GroupAnnouncement_Cell"];
        cell.isDiscuss = self.isDiscuss;
        return cell;
    }else if (indexPath.row == 5 && !self.isDiscuss){
        ECGroupModeCell *cell = [[ECGroupModeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GroupMode_Cell"];
        [cell ec_configMode:[ECBaseCellModel baseModelWithText:NSLocalizedString(@"群设置为公开",nil) detailText:nil img:nil modelType:ec_groupsetvc_cell_switch]];
        return cell;
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CreateGroup_cell"];
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CreateGroup_Cell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        NSDictionary *dic = self.dataArray[indexPath.row];
        cell.textLabel.text = dic[@"titile"];
        cell.detailTextLabel.text = dic[@"sub"];
        return cell;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.isDiscuss?self.dataArray.count - 1:self.dataArray.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UITableViewHeaderFooterView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"CreateGroup_Section"];
    footerView.textLabel.text = @"开启本群为公开群，可被所有用户搜索并申请加入";
    return self.isDiscuss?nil:footerView;
}
- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section{
    UITableViewHeaderFooterView *footerView = (UITableViewHeaderFooterView *)view;
    footerView.textLabel.font = EC_Font_System(13);
    footerView.textLabel.textColor = EC_Color_Sec_Text;
    footerView.tintColor = EC_Color_Clear;
}

#pragma makr - UIPickerView delegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if(self.type == 1){
        self.selectProvince = row;
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        cell.detailTextLabel.text = self.areaArr[row][@"ProvinceName"];
        UITableViewCell *cell2 = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
        NSArray *cityArr = self.areaArr[row][@"cities"];
        NSDictionary *cityDic = cityArr[0];
        cell2.detailTextLabel.text = cityDic[@"CityName"];
        self.selectCity = 0;
    }else if (self.type == 2){
        self.selectCity = row;
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
        NSArray *cityArr = self.areaArr[self.selectProvince][@"cities"];
        NSDictionary *cityDic = cityArr[row];
        cell.detailTextLabel.text = cityDic[@"CityName"];
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if(self.type == 1)
        return self.areaArr.count;
    return [self.areaArr[self.selectProvince][@"cities"] count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if(self.type == 1)
        return self.areaArr[row][@"ProvinceName"];
    NSArray *cityArr = self.areaArr[self.selectProvince][@"cities"];
    NSDictionary *cityDic = cityArr[row];
    return cityDic[@"CityName"];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

#pragma mark - ECBaseContollerDelegate
- (ECBaseItemBlock)baseController:(ECBaseContoller *)baseVC configRightBtnItemWithStr:(NSString *__autoreleasing *)str {
    *str = NSLocalizedString(@"下一步", nil);
    return ^id{
        _picker.hidden = YES;
        ECAddFriendVC *vc = [[ECAddFriendVC alloc] init];
        vc.isEditing = 1;
        vc.groupDeclared = self.groupDeclared;
        vc.type = self.groupType;
        vc.groupMode = self.groupMode;
        vc.isDiscuss = self.isDiscuss;
        vc.selectProvince = self.areaArr[self.selectProvince][@"ProvinceName"];
        NSArray *cityArr = self.areaArr[self.selectProvince][@"cities"];
        NSDictionary *cityDic = cityArr[self.selectCity];
        vc.selectCity = cityDic[@"CityName"];
        ECGroupNameCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        vc.groupName = cell.groupName;
        if (vc.groupName.length == 0) {
            [ECCommonTool toast:@"名称为空,请检查后重新创建"];
            return nil;
        }
        [self.navigationController pushViewController:vc animated:YES];
        return vc;
    };
}
#pragma mark - 创建UI
- (void)buildUI{
    self.baseDelegate = self;
    if ([self.basePushData isKindOfClass:[NSNumber class]])
        self.isDiscuss = [self.basePushData boolValue];
    [self.view addSubview:self.tableView];
    _picker = [[UIPickerView alloc] init];
    _picker.dataSource = self;
    _picker.delegate = self;
    _picker.hidden = YES;
    _picker.showsSelectionIndicator = YES;
    [_picker selectRow: 0 inComponent: 0 animated: YES];
    [self.view addSubview: _picker];
    EC_WS(self);
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.view);
    }];
    [_picker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(weakSelf.view);
        make.height.offset(240.0);
    }];
    NSString *typeTitle = self.isDiscuss?NSLocalizedString(@"讨论组", nil):NSLocalizedString(@"群",nil);
    self.title = [NSString stringWithFormat:@"%@%@",@"创建",typeTitle];
    [self fetchAreaData];
    self.groupMode = ECGroupPermMode_NeedIdAuth;
    NSDictionary *dict = self.isDiscuss?@{}:@{@"titile":[NSString stringWithFormat:@"%@%@",typeTitle,@"设置为公开"], @"sub":@"云通讯"};
    self.dataArray = @[@{@"titile":[NSString stringWithFormat:@"%@%@",typeTitle,@"名称"], @"sub":@"云通讯"}, @{@"titile":@"省份", @"sub":@"选填"}, @{@"titile":@"城市", @"sub":@"选填"}, @{@"titile":[NSString stringWithFormat:@"%@%@",typeTitle,@"公告"], @"sub":@"选填"},@{@"titile":[NSString stringWithFormat:@"%@%@",typeTitle,@"类型"], @"sub":@"选填"},dict
                       ];
    [super buildUI];
}

- (UITableView *)tableView{
    if(!_tableView){
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = EC_Color_VCbg;
        _tableView.tableFooterView = [UIView new];
        _tableView.sectionFooterHeight = 30;
        _tableView.estimatedRowHeight = 44.0;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        [_tableView registerClass:[ECGroupNameCell class] forCellReuseIdentifier:@"GroupName_Cell"];
        [_tableView registerClass:[ECGroupDeclaredCell class] forCellReuseIdentifier:@"GroupAnnouncement_Cell"];
        [_tableView registerClass:[ECGroupModeCell class] forCellReuseIdentifier:@"GroupMode_Cell"];
        [_tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"CreateGroup_Section"];
    }
    return _tableView;
}

@end
