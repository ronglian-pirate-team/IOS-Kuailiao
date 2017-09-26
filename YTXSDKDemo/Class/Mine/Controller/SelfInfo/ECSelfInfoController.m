//
//  ECSelfInfoVC.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/23.
//
//

#import "ECSelfInfoController.h"
#import "ECSexUpdateVC.h"
#import "ECNickNameSetVC.h"
#import "ECSignSetVC.h"
#import "ECAgeSetVC.h"
#import "ECSelfHeaderCell.h"
#import "ECFriendManager.h"

@interface ECSelfInfoController ()<UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation ECSelfInfoController

#pragma mark - UIImagePickerController delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *orgImage = info[UIImagePickerControllerEditedImage];
    
    EC_ShowHUD(NSLocalizedString(@"正在上传头像", nil));
    [[ECFriendManager sharedInstanced] uploadImage:orgImage completion:^(NSString *errCode) {
        EC_HideHUD;
        if (errCode.integerValue == 0)
            [[NSNotificationCenter defaultCenter] postNotificationName:EC_DEMO_KNotice_UpdateSelfInfo object:nil];
        else
            [ECCommonTool toast:@"头像上传失败"];
    }];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 2)
        return;
    UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    if(buttonIndex == 0){
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }else if (buttonIndex == 1){
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - UITableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 0){
        if(indexPath.row == 0){
            UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"设置头像", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"拍摄", nil), NSLocalizedString(@"相册选取", nil), nil];
            [action showInView:self.view];
        }else if(indexPath.row == 1){
            ECNickNameSetVC *sexUpdateVC = [[ECNickNameSetVC alloc] init];
            [self.navigationController pushViewController:sexUpdateVC animated:YES];
        }else if (indexPath.row == 2){
            ECAgeSetVC *ageUpdateVC = [[ECAgeSetVC alloc] init];
            [self.navigationController pushViewController:ageUpdateVC animated:YES];
        }
    }else if (indexPath.section == 1){
        if(indexPath.row == 0){
            ECSexUpdateVC *sexUpdateVC = [[ECSexUpdateVC alloc] init];
            [self.navigationController pushViewController:sexUpdateVC animated:YES];
        }else if (indexPath.row == 1){
            ECSignSetVC *signUpdateVC = [[ECSignSetVC alloc] init];
            [self.navigationController pushViewController:signUpdateVC animated:YES];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0 && indexPath.row == 0){
        ECSelfHeaderCell *headCell = [tableView dequeueReusableCellWithIdentifier:@"ECPersonalHeaderInfo_Cell"];
        headCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        headCell.textLabel.text = self.dataArray[indexPath.section][indexPath.row];
        NSString *placeholderImage = [ECDevicePersonInfo sharedInstanced].sex == ECSexType_Male ? @"headerMan" : @"headerWoman";
        [headCell.headImage sd_setImageWithURL:[NSURL URLWithString:[ECDevicePersonInfo sharedInstanced].avatar] placeholderImage:EC_Image_Named(placeholderImage)];
        return headCell;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ECPersonalInfo_Cell"];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ECPersonalInfo_Cell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = self.dataArray[indexPath.section][indexPath.row];
    if(indexPath.section == 0){
        if (indexPath.row == 1){
            cell.detailTextLabel.text = [ECDevicePersonInfo sharedInstanced].nickName;
        }else if (indexPath.row == 2){
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", [NSDate ageWithDateStr:[ECDevicePersonInfo sharedInstanced].birth]];
        }
    }else if (indexPath.section == 1){
        if(indexPath.row == 0){
            cell.detailTextLabel.text = [ECDevicePersonInfo sharedInstanced].sex == ECSexType_Male ? @"男" : @"女";
        }else if (indexPath.row == 1){
            cell.detailTextLabel.text = [ECDevicePersonInfo sharedInstanced].sign;
        }
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section == 0 ? 3 : 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return (indexPath.section == 0 && indexPath.row == 0) ? 74 : 44;
}

#pragma mark - UI 创建
- (void)buildUI{
    self.title = NSLocalizedString(@"个人信息", nil);
    [self.view addSubview:self.tableView];
    EC_WS(self)
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf);
    }];
    self.dataArray = @[@[NSLocalizedString(@"头像", nil), NSLocalizedString(@"昵称", nil), NSLocalizedString(@"年龄", nil)], @[NSLocalizedString(@"性别", nil), NSLocalizedString(@"签名", nil)]];

    [super buildUI];
}

- (void)ec_addNotify {
    [[NSNotificationCenter defaultCenter] addObserverForName:EC_DEMO_KNotice_UpdateSelfInfo object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [self.tableView reloadData];
    }];
}

#pragma mark - 懒加载
- (UITableView *)tableView{
    if(!_tableView){
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.backgroundColor = EC_Color_VCbg;
        [_tableView registerClass:[ECSelfHeaderCell class] forCellReuseIdentifier:@"ECPersonalHeaderInfo_Cell"];
    }
    return _tableView;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
