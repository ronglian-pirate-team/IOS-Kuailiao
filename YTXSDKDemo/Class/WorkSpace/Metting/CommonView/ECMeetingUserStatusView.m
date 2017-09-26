//
//  ECMeetingUserStatusView.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/18.
//
//

#import "ECMeetingUserStatusView.h"

@interface ECMeetingUserStatusView()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation ECMeetingUserStatusView

- (instancetype)init{
    if(self = [super init]){
        self.delegate = self;
        self.dataSource = self;
        self.separatorColor = EC_Color_Tabbar;
        self.rowHeight = 30;
        self.backgroundColor = EC_Color_Tabbar;
        self.showsVerticalScrollIndicator = NO;
        self.tableSource = [NSMutableArray array];
        [self registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ECVoiceMeeting_Cell"];
    }
    return self;
}

- (void)setTableSource:(NSMutableArray *)tableSource{
    _tableSource = tableSource;
    [self reloadData];
}

#pragma mark - UITable View Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ECVoiceMeeting_Cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textColor = EC_Color_Sec_Text;
    cell.textLabel.font = EC_Font_System(13);
    cell.textLabel.text = self.tableSource[indexPath.row];
    cell.contentView.backgroundColor = EC_Color_Tabbar;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.tableSource.count;
}

@end
