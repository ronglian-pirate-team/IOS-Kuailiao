//
//  ECSettingController.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/24.
//

#import "ECSettingController.h"
#import "ECBaseCellModel.h"
#import <objc/runtime.h>

#define EC_TABLECELL_DisclosureIndicator_None @"EC_TABLECELL_DisclosureIndicator_None"
#define EC_TABLECELL_DisclosureIndicator_SWITCH @"EC_TABLECELL_DisclosureIndicator_SWITCH"

#define TAG_SwitchSound     1000
#define TAG_SwitchShake     1001
#define TAG_SwitchPlayEar   1002
#define TAG_SwitchFriendValidate   1003

#define EC_SETTING_TITLE_SOUND       @"新消息声音"
#define EC_SETTING_TITLE_SHAKE       @"新消息震动"
#define EC_SETTING_TITLE_FriendValidate       @"好友验证"
#define EC_SETTING_TITLE_EAR         @"听筒模式"
#define EC_SETTING_TITLE_APPVERSION  @"当前版本"
#define EC_SETTING_TITLE_CODE        @"设置编解码"
#define EC_SETTING_TITLE_RESOLUTION  @"当前分辨率:"
#define EC_SETTING_TITLE_VIDEOMODEL  @"视频显示Model:"
#define EC_SETTING_TITLE_EIXT        @"退出当前账号"


@interface ECSettingController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UIActionSheetDelegate>
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) NSArray *dataArray;
@end

@implementation ECSettingController

#pragma mark - 设置编码
- (void)setCodecBtnClicked {
    UIViewController* viewController = [[NSClassFromString(@"ECSetSDKCodeController") alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - 设置分辨率和视频显示
const char  KButtonLabelSheet;
- (void)videoVievModeBtnClicked:(ECBaseCellModel *)model {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"视频View.contentMode" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"ScaleToFill",@"ScaleAspectFit",@"ScaleAspectFill",nil];
    sheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    sheet.tag = 101;
    objc_setAssociatedObject(sheet, &KButtonLabelSheet, model, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [sheet showInView:self.view];
}

- (void)videoResolutionBtnClicked:(ECBaseCellModel *)model {
    CameraDeviceInfo *camera = [[ECDeviceVoipHelper sharedInstanced].cameraInfoArray objectAtIndex:0];
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"设置分辨率" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:nil];
    for (CameraCapabilityInfo *capability in camera.capabilityArray) {
        [sheet addButtonWithTitle:[NSString stringWithFormat:@"%ldx%ld",capability.width,capability.height]];
    }
    sheet.tag = 100;
    sheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    objc_setAssociatedObject(sheet, &KButtonLabelSheet, model, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [sheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    ECBaseCellModel *model = objc_getAssociatedObject(actionSheet, &KButtonLabelSheet);
    if (buttonIndex!=actionSheet.cancelButtonIndex) {
        switch (actionSheet.tag) {
            case 100: {
                NSString *text = [NSString stringWithFormat:@"%@%@",EC_SETTING_TITLE_RESOLUTION,[actionSheet buttonTitleAtIndex:buttonIndex]];
                model.text = text;
                [self.myTableView reloadData];
                [[ECDeviceVoipHelper sharedInstanced] setCurResolutionIndex:buttonIndex-1];
                [[ECDeviceVoipHelper sharedInstanced] selectCamera:0];
            }
                break;
                
            case 101: {
                NSString *btnTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
                NSString *text = [NSString stringWithFormat:@"%@%@",EC_SETTING_TITLE_VIDEOMODEL,[actionSheet buttonTitleAtIndex:buttonIndex]];
                model.text = text;
                [self.myTableView reloadData];
                [[ECAppInfo sharedInstanced] setViewcontentMode:[[ECAppInfo sharedInstanced] viewContentModeFromStr:btnTitle]];
            }
                break;
                
            default:
                break;
        }
        
    }
}
#pragma mark - exit
-(void)exitBtnClicked {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"注销" message:@"确认要退出当前账号吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = 101;
    [alertView show];
}
#pragma mark - 处理switch事件
- (void)switchBtnChanged:(UISwitch *)switchBtn {
    EC_Demo_AppLog(@"settingvc switchBtnChanged:%d",(int)switchBtn.tag);
    switch (switchBtn.tag) {
        case TAG_SwitchSound:
            [ECDeviceDelegateConfigCenter sharedInstanced].isMessageSound = switchBtn.isOn;
            break;
        case TAG_SwitchShake:
            [ECDeviceDelegateConfigCenter sharedInstanced].isMessageShake = switchBtn.isOn;
            break;
        case TAG_SwitchPlayEar:
            [ECDeviceDelegateConfigCenter sharedInstanced].isPlayEar = switchBtn.isOn;
            break;
        case TAG_SwitchFriendValidate:{
            ECRequestUserVerifySet *set = [[ECRequestUserVerifySet alloc] init];
            set.useracc = [ECSDK_Key stringByAppendingFormat:@"#%@",[ECDevicePersonInfo sharedInstanced].userName];
            set.addVerify = ([ECDevicePersonInfo sharedInstanced].isNeedConfirm ? @"0" : @"1");
            EC_ShowHUD(@"")
            [[ECAFNHttpTool sharedInstanced] userVerifySet:set completion:^(NSString *errCode, id responseObject) {
                EC_HideHUD
                if(errCode.integerValue == 0){
                    [ECDevicePersonInfo sharedInstanced].isNeedConfirm = switchBtn.on;
                }else{
                    switchBtn.on = !switchBtn.on;
                }
            }];
        }
            break;
        default:
            break;
    }
}
#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"SettingTableCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    ECBaseCellModel *cellModel = _dataArray[indexPath.section][indexPath.row];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    if ([cellModel.modelType isEqualToString:EC_TABLECELL_DisclosureIndicator_SWITCH]) {
        UISwitch *switchBtn = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 50.0f, 40.0f)];
        if ([cellModel.text isEqualToString:EC_SETTING_TITLE_SOUND]) {
            switchBtn.tag = TAG_SwitchSound;
            switchBtn.on = [ECDeviceDelegateConfigCenter sharedInstanced].isMessageSound;
        } else if ([cellModel.text isEqualToString:EC_SETTING_TITLE_SHAKE]) {
            switchBtn.tag = TAG_SwitchShake;
            switchBtn.on = [ECDeviceDelegateConfigCenter sharedInstanced].isMessageShake;
        } else if ([cellModel.text isEqualToString:EC_SETTING_TITLE_EAR]) {
            switchBtn.tag = TAG_SwitchPlayEar;
            switchBtn.on = [ECDeviceDelegateConfigCenter sharedInstanced].isPlayEar;
        } else if ([cellModel.text isEqualToString:EC_SETTING_TITLE_FriendValidate]) {
            switchBtn.on = [ECDevicePersonInfo sharedInstanced].isNeedConfirm;
            switchBtn.tag = TAG_SwitchFriendValidate;
        }
        [switchBtn addTarget:self action:@selector(switchBtnChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = switchBtn;
    }else{
        cell.accessoryView = nil;
    }
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.text = cellModel.text;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ECBaseCellModel *cellModel = _dataArray[indexPath.section][indexPath.row];
    if ([cellModel.text isEqualToString:EC_SETTING_TITLE_CODE]) {
        [self setCodecBtnClicked];
    } else if ([cellModel.text containsString:EC_SETTING_TITLE_RESOLUTION]) {
        [self videoResolutionBtnClicked:cellModel];;
    } else if ([cellModel.text containsString:EC_SETTING_TITLE_VIDEOMODEL]) {
        [self videoVievModeBtnClicked:cellModel];
    } else if ([cellModel.text isEqualToString:EC_SETTING_TITLE_EIXT]) {
        [self exitBtnClicked];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        if (alertView.tag == 101) {
            
            MBProgressHUD *hub = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hub.removeFromSuperViewOnHide = YES;
            hub.label.text = @"正在注销...";
            EC_WS(self);
            [[ECDevice sharedInstance] logout:^(ECError *error) {
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                
                [ECDevicePersonInfo sharedInstanced].userPassword = nil;
                [ECDevicePersonInfo sharedInstanced].avatar = nil;
                dispatch_async(dispatch_get_main_queue(), ^{
                    //为了页面的跳转，使用了该错误码，用户在使用过程中，可以自定义消息，或错误码值
                    [[NSNotificationCenter defaultCenter] postNotificationName:EC_DEMO_kNotification_EixtSucess object:[ECError errorWithCode:10]];
                });
            }];
        }
    }
}
#pragma mark - UI创建
- (void)buildUI {
    self.title = NSLocalizedString(@"设置", nil);
    [self.view addSubview:self.myTableView];
    //视频分辨率
    CameraDeviceInfo *camera = [[ECDeviceVoipHelper sharedInstanced].cameraInfoArray objectAtIndex:0];
    CameraCapabilityInfo *capability = [camera.capabilityArray objectAtIndex:[ECDeviceVoipHelper sharedInstanced].curResolutionIndex];
    NSString *model = [[ECAppInfo sharedInstanced] viewContentModeToStr:[ECAppInfo sharedInstanced].viewcontentMode];
    _dataArray = @[
                   @[[ECBaseCellModel baseModelWithText:EC_SETTING_TITLE_SOUND detailText:nil img:nil modelType:EC_TABLECELL_DisclosureIndicator_SWITCH],
                     [ECBaseCellModel baseModelWithText:EC_SETTING_TITLE_SHAKE detailText:nil img:nil modelType:EC_TABLECELL_DisclosureIndicator_SWITCH]],
                   @[[ECBaseCellModel baseModelWithText:EC_SETTING_TITLE_FriendValidate detailText:nil img:nil modelType:EC_TABLECELL_DisclosureIndicator_SWITCH]],
                   @[[ECBaseCellModel baseModelWithText:EC_SETTING_TITLE_EAR detailText:nil img:nil modelType:EC_TABLECELL_DisclosureIndicator_SWITCH]],
                   @[[ECBaseCellModel baseModelWithText:[NSString stringWithFormat:@"%@(%@)",EC_SETTING_TITLE_APPVERSION,EC_APPVersion] detailText:nil img:nil modelType:EC_TABLECELL_DisclosureIndicator_None]],
                   @[[ECBaseCellModel baseModelWithText:EC_SETTING_TITLE_CODE detailText:nil img:nil modelType:EC_TABLECELL_DisclosureIndicator_None],
                     [ECBaseCellModel baseModelWithText:[NSString stringWithFormat:@"%@%ldx%ld",EC_SETTING_TITLE_RESOLUTION,capability.width,capability.height] detailText:nil img:nil modelType:EC_TABLECELL_DisclosureIndicator_None],
                     [ECBaseCellModel baseModelWithText:[NSString stringWithFormat:@"%@%@",EC_SETTING_TITLE_VIDEOMODEL,model] detailText:nil img:nil modelType:EC_TABLECELL_DisclosureIndicator_None]],
                   @[[ECBaseCellModel baseModelWithText:EC_SETTING_TITLE_EIXT detailText:nil img:nil modelType:EC_TABLECELL_DisclosureIndicator_None]],
                   ];
    
    [super buildUI];
}

#pragma mark - 懒加载
- (UITableView *)myTableView {
    if (!_myTableView) {
        _myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
        _myTableView.delegate = self;
        _myTableView.dataSource = self;
        _myTableView.tableFooterView = [[UIView alloc] init];
    }
    return _myTableView;
}
@end
