//
//  ECAgeUpdateVC.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/24.
//
//

#import "ECSexUpdateVC.h"

@interface ECSexUpdateVC ()<UITableViewDelegate, UITableViewDataSource, ECBaseContollerDelegate>

@property (nonatomic, weak) NSIndexPath *selectIndex;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ECSexUpdateVC

- (void)viewDidLoad {
    self.baseDelegate = self;
    [super viewDidLoad];
}

- (ECBaseItemBlock)baseController:(ECBaseContoller *)baseVC configRightBtnItemWithStr:(NSString *__autoreleasing *)str{
    *str = NSLocalizedString(@"保存", nil);
    return ^id {
        ECPersonInfo *person = [[ECPersonInfo alloc] init];
        person.nickName = [ECDevicePersonInfo sharedInstanced].nickName;
        person.sex = self.selectIndex.row + 1;
        person.birth = [ECDevicePersonInfo sharedInstanced].birth;
        person.sign = [ECDevicePersonInfo sharedInstanced].sign;
        EC_WS(self)
        [[ECDevice sharedInstance] setPersonInfo:person completion:^(ECError *error, ECPersonInfo *person) {
            if (error.errorCode == ECErrorType_NoError) {
                [ECDevicePersonInfo sharedInstanced].sex = weakSelf.selectIndex.row + 1;
                [[NSNotificationCenter defaultCenter] postNotificationName:EC_DEMO_KNotice_UpdateSelfInfo object:nil];
                [ECDevicePersonInfo sharedInstanced].dataVersion = person.version;
                [weakSelf.navigationController popViewControllerAnimated:YES];
            } else {
                NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\r描述:%@",error.errorDescription]:@"";
                [ECCommonTool toast:detail];
            }
        }];
        return nil;
    };
}

#pragma mark - UITableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.selectIndex){
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:self.selectIndex];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    self.selectIndex = indexPath;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ECAgeUpdate_Cell"];
    cell.textLabel.text = indexPath.row == 0 ? NSLocalizedString(@"男", nil) : NSLocalizedString(@"女", nil);
    if(indexPath.row == 0 && [ECDevicePersonInfo sharedInstanced].sex == ECSexType_Male){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.selectIndex = indexPath;
    }else if(indexPath.row == 1 && [ECDevicePersonInfo sharedInstanced].sex == ECSexType_Female){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.selectIndex = indexPath;
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (void)buildUI{
    [super buildUI];
    self.title = NSLocalizedString(@"性别", nil);
    [self.view addSubview:self.tableView];
    EC_WS(self)
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf);
    }];
}

- (UITableView *)tableView{
    if(!_tableView){
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.backgroundColor = EC_Color_VCbg;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ECAgeUpdate_Cell"];
    }
    return _tableView;
}

@end
