//
//  ECAboutController.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/24.
//

#import "ECAboutController.h"
#import "ECWebBaseController.h"
#import "ECBaseCellModel.h"
#import "ECAboutHeaderView.h"

#define EC_WebUrlPlist @"YTXLinkUrl.plist"

#define OfficalWeb @"OfficalWeb"
#define IMPlusWeb @"IMPlusWeb"
#define DeveloperDocWeb @"DeveloperDocWeb"
#define ReleaseNoteWeb @"ReleaseNoteWeb"
#define ErrorWeb @"ErrorWeb"
#define DowloadWeb @"DowloadWeb"

@interface ECAboutController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *myTableview;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSDictionary *linkDict;
@end

@implementation ECAboutController

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"aboutTableCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = [UIColor whiteColor];
    }
    ECBaseCellModel *cellModel = [_dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text = cellModel.text;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ECBaseCellModel *cellModel = [_dataArray objectAtIndex:indexPath.row];
    NSString *urlStr  = [self.linkDict objectForKey:cellModel.modelType];
    ECWebBaseController *webVC = [[ECWebBaseController alloc] initWithUrlStr:urlStr andType:ECWebBaseController_Type_Link completion:nil];
    [self.navigationController pushViewController:webVC animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[ECAboutHeaderView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return EC_AHeadViewHeight;
}
#pragma mark - UI创建
- (void)buildUI {
    self.title = NSLocalizedString(@"关于我们", nil);
    [self.view addSubview:self.myTableview];
    _dataArray = @[[ECBaseCellModel baseModelWithText:@"官方网站" detailText:nil img:nil modelType:OfficalWeb],
                   [ECBaseCellModel baseModelWithText:@"IMPlus平台详细功能" detailText:nil img:nil modelType:IMPlusWeb],
                   [ECBaseCellModel baseModelWithText:@"开发文档" detailText:nil img:nil modelType:DeveloperDocWeb],
                   [ECBaseCellModel baseModelWithText:@"更新日志" detailText:nil img:nil modelType:ReleaseNoteWeb],
                   [ECBaseCellModel baseModelWithText:@"错误码" detailText:nil img:nil modelType:ErrorWeb],
                   ];
    [super buildUI];
}

#pragma mark - 懒加载
- (UITableView *)myTableview {
    if (!_myTableview) {
        _myTableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
        _myTableview.delegate =self;
        _myTableview.dataSource = self;
        _myTableview.tableFooterView = [[UIView alloc] init];
    }
    return _myTableview;
}

- (NSDictionary *)linkDict {
    if (!_linkDict) {
        _linkDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:EC_WebUrlPlist ofType:nil]];
    }
    return _linkDict;
}
@end
