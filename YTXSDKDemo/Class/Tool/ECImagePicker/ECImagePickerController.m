//
//  ECImagePickerController.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/9/11.
//

#import "ECImagePickerController.h"
#import "ECDemoChatManager.h"

@interface ECImagePickerController ()<UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic, copy) NSString *sessionId;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray  *dataSource;
@end

@implementation ECImagePickerController

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [ECAlertController alertControllerWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"是否确认设置为聊天背景", nil) cancelTitle:NSLocalizedString(@"取消", nil) DestructiveTitle:nil DefautTitleArray:@[NSLocalizedString(@"确认", nil)] showInView:picker handler:^(UIAlertAction *action) {
        if ([action.title isEqualToString:NSLocalizedString(@"确认", nil)]) {
            NSString *mediaType = info[UIImagePickerControllerMediaType];
            if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
                UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
                [[ECDemoChatManager sharedInstanced] ec_chatBackgroundImageOfSessionId:self.sessionId sourceImg:orgImage];
            }
        }
        [picker dismissViewControllerAnimated:YES completion:nil];
    }];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ECBaseCellModel *model = self.dataSource[indexPath.row];
    UIImagePickerController *pickerVC = [[UIImagePickerController alloc] init];
    pickerVC.delegate = self;
    pickerVC.mediaTypes = @[(NSString *)kUTTypeImage];
    if ([model.text isEqualToString:NSLocalizedString(@"从手机相册选择",nil)]) {
        pickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:pickerVC animated:YES completion:nil];
    } else if ([model.text isEqualToString:NSLocalizedString(@"拍一张",nil)]) {
        if ([UIImagePickerController isSourceTypeAvailable:(UIImagePickerControllerSourceTypeCamera)]) {
            pickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
        } else {
            UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"设备不支持摄像头" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alterView show];
        }
        [self presentViewController:pickerVC animated:YES completion:nil];
    } else if ([model.text isEqualToString:NSLocalizedString(@"移除背景图",nil)]) {
        [[ECDemoChatManager sharedInstanced] ec_removeChatBackgroundImageOfSessionId:self.sessionId];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ECBaseCellModel *model = self.dataSource[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ec_imagepicker_cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ec_imagepicker_cell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = model.text;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

#pragma mark - UI创建
- (void)buildUI {
    self.sessionId = self.basePushData;
    self.title = NSLocalizedString(@"聊天背景", nil);
    [self.view addSubview:self.tableView];
    [super buildUI];
}

- (void)ec_addNotify {
    self.dataSource = [NSMutableArray arrayWithArray:@[
                                                       [ECBaseCellModel baseModelWithText:@"从手机相册选择" detailText:nil img:nil modelType:nil],
                                                       [ECBaseCellModel baseModelWithText:@"拍一张" detailText:nil img:nil modelType:nil],
                                                       [ECBaseCellModel baseModelWithText:@"移除背景图" detailText:nil img:nil modelType:nil]
                                                       ]
                       ];
}
#pragma mark - 懒加载
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 48.0f;
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

@end
