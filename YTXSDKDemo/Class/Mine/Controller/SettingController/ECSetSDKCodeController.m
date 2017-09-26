//
//  ECSetSDKCodeController.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/24.
//

#import "ECSetSDKCodeController.h"
#import "ECBaseCellModel.h"

#define EC_TABLECELL_DisclosureIndicator_SWITCH @"EC_TABLECELL_DisclosureIndicator_SWITCH"

@interface ECSetSDKCodeController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UIActionSheetDelegate>
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) NSArray *dataArray;
@end

@implementation ECSetSDKCodeController

#pragma mark - 处理switch事件
- (void)switchBtnChanged:(UISwitch *)switchBtn {
    EC_Demo_AppLog(@"ECSetSDKCodeController switchBtnChanged:%d",(int)switchBtn.tag);
    [[ECDeviceVoipHelper sharedInstanced] SetSDKCodecType:switchBtn.tag andEnable:switchBtn.isOn];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"SettingSDKCodeTableCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    ECBaseCellModel *cellModel = _dataArray[indexPath.row];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        UISwitch *switchBtn = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 50.0f, 40.0f)];
        BOOL isOn = [[ECDeviceVoipHelper sharedInstanced] GetSDKIsEnableCodecType:cellModel.modelType.intValue];
        switchBtn.on = isOn;
        switchBtn.tag = cellModel.modelType.intValue;
        [switchBtn addTarget:self action:@selector(switchBtnChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = switchBtn;
    }
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.text = cellModel.text;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}
#pragma mark - UI创建
- (void)buildUI {
    self.title = NSLocalizedString(@"编解码设置", nil);
    [self.view addSubview:self.myTableView];
    
    _dataArray = @[
//                   [ECBaseCellModel baseModelWithText:@"Codec_iLBC" detailText:nil img:nil modelType:@"0"],
                   [ECBaseCellModel baseModelWithText:@"Codec_G729" detailText:nil img:nil modelType:@"1"],
                   [ECBaseCellModel baseModelWithText:@"Codec_PCMU" detailText:nil img:nil modelType:@"2"],
//                   [ECBaseCellModel baseModelWithText:@"Codec_PCMA" detailText:nil img:nil modelType:@"3"],
                   [ECBaseCellModel baseModelWithText:@"Codec_H264" detailText:nil img:nil modelType:@"4"],
//                   [ECBaseCellModel baseModelWithText:@"Codec_SILK8K" detailText:nil img:nil modelType:@"5"],
//                   [ECBaseCellModel baseModelWithText:@"Codec_AMR" detailText:nil img:nil modelType:@"6"],
                   [ECBaseCellModel baseModelWithText:@"Codec_VP8" detailText:nil img:nil modelType:@"7"],
//                   [ECBaseCellModel baseModelWithText:@"Codec_SILK16K" detailText:nil img:nil modelType:@"8"],
                   [ECBaseCellModel baseModelWithText:@"Codec_OPUS48" detailText:nil img:nil modelType:@"9"],
                   [ECBaseCellModel baseModelWithText:@"Codec_OPUS16" detailText:nil img:nil modelType:@"10"],
                   [ECBaseCellModel baseModelWithText:@"Codec_OPUS8" detailText:nil img:nil modelType:@"11"],
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
