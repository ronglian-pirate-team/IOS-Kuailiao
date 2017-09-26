//
//  ECGroupModeCell.m
//  YTXSDKDemo
//
//  Created by xt on 2017/7/27.
//
//

#import "ECGroupModeCell.h"
#import "ECDemoGroupManage.h"

@interface ECGroupModeCell()
@property (nonatomic, strong)UISwitch *switchView;
@property (nonatomic, strong) ECBaseCellModel *model;
@end

@implementation ECGroupModeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)switchAction:(UISwitch *)switchView {
    if ([_model.text isEqualToString:ec_group_noticetext])
        [[ECDemoGroupManage sharedInstanced] groupNoticeSet:self.switchView.isOn];
    else if ([_model.text isEqualToString:ec_group_pushapnstext])
        [[ECDemoGroupManage sharedInstanced] groupAPNSSet:self.switchView.isOn];
     else if ([_model.text isEqualToString:ec_group_settoptext]) {
         EC_WS(self);
         [[ECAppInfo sharedInstanced].sessionMgr ec_setSessionTop:self.switchView.on completion:^(ECError *error, NSString *seesionId) {
             if (error.errorCode != ECErrorType_NoError) {
                 weakSelf.switchView.on = !weakSelf.switchView.on;
             }
         }];
     }
    else
        self.isOpen = self.switchView.isOn;
}

- (void)ec_configMode:(ECBaseCellModel *)cellModel {
    _model = cellModel;
    self.textLabel.text = cellModel.text;
    self.detailTextLabel.text = cellModel.detailText;
    self.textLabel.textColor = EC_Color_Main_Text;
    self.textLabel.textAlignment = NSTextAlignmentLeft;
    if ([cellModel.modelType isEqualToString:ec_groupsetvc_cell_switch]) {
        self.switchView = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 50.0f, 40.0f)];
        [self.switchView addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];   // 开关事件切换通知
        self.accessoryView = self.switchView;
        if ([cellModel.text isEqualToString:ec_group_noticetext])
            self.switchView.on = ![ECDemoGroupManage sharedInstanced].group.isNotice;
        else if ([cellModel.text isEqualToString:ec_group_pushapnstext])
            self.switchView.on = [ECDemoGroupManage sharedInstanced].group.isPushAPNS;
        else if ([cellModel.text isEqualToString:ec_group_settoptext]) {
            self.switchView.on = [ECAppInfo sharedInstanced].sessionMgr.session.isTop;
        }
        else if ([cellModel.text isEqualToString:ec_meetingl_autodelete]){
            self.switchView.on = YES;
            self.isOpen = YES;
        }else if ([cellModel.text isEqualToString:ec_meetingl_autodismiss]){
            self.switchView.on = YES;
            self.isOpen = YES;
        }else if ([cellModel.text isEqualToString:ec_meetingl_autojoin]){
            self.switchView.on = YES;
            self.isOpen = YES;
        }else if ([cellModel.text isEqualToString:ec_group_create_open]){
            self.switchView.on = YES;
            self.isOpen = YES;
        }
    } else if ([cellModel.modelType isEqualToString:ec_groupsetvc_cell_disclosureIndicator]) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if ([cellModel.modelType isEqualToString:ec_groupsetvc_cell_attact]) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        NSTextAttachment *attach = [[NSTextAttachment alloc] init];
        attach.image = EC_Image_Named(@"qunzusettingIconErweima");
        NSAttributedString *attributeStr = [NSAttributedString attributedStringWithAttachment:attach];
        self.detailTextLabel.attributedText = attributeStr;
    } else if ([cellModel.modelType isEqualToString:ec_groupsetvc_cell_centerText]) {
        self.accessoryView = nil;
        self.textLabel.textColor = EC_Color_Alert_Red;
        self.textLabel.textAlignment = NSTextAlignmentCenter;
    }else if (cellModel.modelType == nil){
        self.accessoryView = nil;
    }
}

@end
