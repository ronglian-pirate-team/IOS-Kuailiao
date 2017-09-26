//
//  ECAgeSetVC.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/24.
//
//

#import "ECAgeSetVC.h"

@interface ECAgeSetVC ()<ECBaseContollerDelegate>

@property (nonatomic, strong) UIDatePicker *dataPicker;
@property (nonatomic, strong) UILabel *ageLabel;

@end

@implementation ECAgeSetVC

- (void)viewDidLoad {
    self.baseDelegate = self;
    [super viewDidLoad];
}

- (void)changeDate:(UIDatePicker *)datePicker{
    self.ageLabel.text = [NSString stringWithFormat:@"%ld", [NSDate ageWithDateOfBirth:datePicker.date]];
}

- (NSString *)getDateStr:(NSDate *)date{
    NSDateFormatter *dateFormate = [[NSDateFormatter alloc] init];
    [dateFormate setDateFormat:@"yyyy-MM-dd"];
    NSString *dateStr = [dateFormate stringFromDate:date];
    return dateStr;
}

#pragma mark - ECBaseContollerDelegate
- (ECBaseItemBlock)baseController:(ECBaseContoller *)baseVC configRightBtnItemWithStr:(NSString *__autoreleasing *)str {
    *str = NSLocalizedString(@"保存", nil);
    return ^id {
        if([NSDate ageWithDateOfBirth:self.dataPicker.date] < 0){
            [ECCommonTool toast:@"设置时间大于当前时间"];
            return nil;
        }
        ECPersonInfo *person = [[ECPersonInfo alloc] init];
        person.nickName = [ECDevicePersonInfo sharedInstanced].nickName;
        person.sex = [ECDevicePersonInfo sharedInstanced].sex;
        person.birth = [self getDateStr:self.dataPicker.date];
        person.sign = [ECDevicePersonInfo sharedInstanced].sign;
        EC_WS(self)
        [[ECDevice sharedInstance] setPersonInfo:person completion:^(ECError *error, ECPersonInfo *person) {
            if (error.errorCode == ECErrorType_NoError) {
                [ECDevicePersonInfo sharedInstanced].birth = [self getDateStr:weakSelf.dataPicker.date];
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

#pragma mark - UI创建
- (void)buildUI{
    [super buildUI];
    self.title = NSLocalizedString(@"年龄", nil);
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 80, EC_kScreenW, 44)];
    contentView.backgroundColor = EC_Color_White;
    [self.view addSubview:contentView];
    UILabel *titlLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, 100, 44)];
    titlLabel.textColor = EC_Color_Main_Text;
    titlLabel.font = EC_Font_System(15);
    titlLabel.text = NSLocalizedString(@"年龄", nil);
    [contentView addSubview:titlLabel];
    self.ageLabel = [[UILabel alloc] initWithFrame:CGRectMake(EC_kScreenW - 112, 0, 100, 44)];
    self.ageLabel.font = EC_Font_System(15);
    self.ageLabel.textColor = EC_Color_Sec_Text;
    self.ageLabel.textAlignment = NSTextAlignmentRight;
    self.ageLabel.text = [NSString stringWithFormat:@"%ld", [NSDate ageWithDateStr:[ECDevicePersonInfo sharedInstanced].birth]];
    [contentView addSubview:self.ageLabel];
    self.dataPicker = [[UIDatePicker alloc] init];
    self.dataPicker.datePickerMode = UIDatePickerModeDate;
    self.dataPicker.frame = CGRectMake(0, EC_kScreenH - 280, EC_kScreenW, 280);
    [self.dataPicker addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.dataPicker];
}

@end
