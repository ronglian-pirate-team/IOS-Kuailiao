//
//  ECGroupAdminManagerVC.m
//  YTXSDKDemo
//
//  Created by xt on 2017/9/2.
//
//

#import "ECGroupAdminManagerVC.h"

@interface ECGroupAdminManagerVC ()

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ECGroupAdminManagerVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)buildUI{
    self.title = NSLocalizedString(@"设置管理员", nil);
    
}

@end
