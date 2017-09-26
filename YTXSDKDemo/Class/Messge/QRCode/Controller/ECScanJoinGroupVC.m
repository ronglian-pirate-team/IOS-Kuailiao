//
//  ECScanJoinGroupVC.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/1.
//
//

#import "ECScanJoinGroupVC.h"

@interface ECScanJoinGroupVC ()

@end

@implementation ECScanJoinGroupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"申请加入";
}

- (void)joinAction{
    EC_ShowHUD(NSLocalizedString(@"正在加入,请稍后...", nil));
    ECRequestQRJoinGroup *request = [[ECRequestQRJoinGroup alloc] init];
    request.groupId = self.dataDic[@"groupid"];
    request.generateQrUserName = self.dataDic[@"creator"];
    request.codeCreateTime = self.dataDic[@"time"];
    [[ECAFNHttpTool sharedInstanced] joinQRCodeGroupId:request completion:^(NSInteger code, NSString *errStr) {
        EC_HideHUD;
        if (code==0 || code == ECErrorType_Have_Joined) {
            ECSession *session = [[ECSession alloc] initWithSessionId:request.groupId];
            [[NSNotificationCenter defaultCenter] postNotificationName:EC_DEMO_kNotification_ClickSession object:session];
            UIViewController *vc = [[NSClassFromString(@"ECChatController") alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [[AppDelegate sharedInstanced].rootNav setViewControllers:[NSArray arrayWithObjects:[weakSelf.navigationController.viewControllers objectAtIndex:0],vc, nil] animated:YES];
        } else {
            EC_Demo_AppLog(@"joinQRCodeGroupId %d",(int)code);
            [ECCommonTool toast:@"扫描二维码加入群失败"];
        }
    }];
}

- (void)buildUI{
    self.view.backgroundColor = EC_Color_VCbg;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:EC_Image_Named(@"messageIconQunzu")];
    [self.view addSubview:imageView];
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.font = EC_Font_System(16);
    nameLabel.textColor = EC_Color_Main_Text;
    nameLabel.text = self.dataDic[@"name"] ? self.dataDic[@"name"] : self.dataDic[@"groupid"];
    [nameLabel sizeToFit];
    [self.view addSubview:nameLabel];
    UILabel *countLabel = [[UILabel alloc] init];
    countLabel.text = [NSString stringWithFormat:@"（共%@人）", self.dataDic[@"count"]];
    [countLabel sizeToFit];
    countLabel.textAlignment = NSTextAlignmentCenter;
    countLabel.font = EC_Font_System(13);
    countLabel.textColor = EC_Color_Sec_Text;
    [self.view addSubview:countLabel];
    UILabel *label = [[UILabel alloc] init];
    label.text = @"确认加入群聊";
    [label sizeToFit];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = EC_Font_System(13);
    label.textColor = EC_Color_Sec_Text;
    [self.view addSubview:label];
    UIButton *joinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [joinBtn setTitle:NSLocalizedString(@"加入群聊", nil) forState:UIControlStateNormal];
    [joinBtn setTitleColor:EC_Color_White forState:UIControlStateNormal];
    joinBtn.backgroundColor = EC_Color_App_Main;
    [joinBtn addTarget:self action:@selector(joinAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:joinBtn];
    EC_WS(self)
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf);
        make.top.equalTo(weakSelf).offset(100);
    }];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imageView.mas_bottom).offset(10);
        make.left.right.equalTo(weakSelf);
    }];
    [countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nameLabel.mas_bottom).offset(10);
        make.left.right.equalTo(weakSelf);
    }];

    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(countLabel.mas_bottom).offset(40);
        make.left.right.equalTo(weakSelf);
    }];
    [joinBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(label.mas_bottom).offset(10);
        make.left.equalTo(weakSelf).offset(20);
        make.right.equalTo(weakSelf).offset(-20);
        make.height.offset(40);
    }];
    [super buildUI];
}

@end
