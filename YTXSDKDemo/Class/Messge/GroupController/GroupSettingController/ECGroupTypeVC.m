//
//  ECGroupTypeVC.m
//  YTXSDKDemo
//
//  Created by xt on 2017/7/26.
//
//

#import "ECGroupTypeVC.h"

@interface ECGroupTypeVC ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation ECGroupTypeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择群组类型";
    self.dataArray = @[@"同学", @"朋友", @"同事", @"亲友", @"闺蜜", @"粉丝", @"基友", @"驴友"];
}

#pragma mark - UITableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.selectType)
        self.selectType(indexPath.row, self.dataArray[indexPath.row]);
    [self.navigationController popViewControllerAnimated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Type_Cell"];
    cell.textLabel.text = self.dataArray[indexPath.row];
    cell.textLabel.font = EC_Font_System(15);
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 8;
}

#pragma mark - 创建UI
- (void)buildUI{
    UITableView *tableView = [[UITableView alloc] init];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = EC_Color_VCbg;
    tableView.tableFooterView = [UIView new];
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Type_Cell"];
    [self.view addSubview:tableView];
    EC_WS(self)
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.view);
    }];
    [super buildUI];
}

@end
