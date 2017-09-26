//
//  ECGroupNameCell.m
//  YTXSDKDemo
//
//  Created by xt on 2017/7/27.
//
//

#import "ECGroupNameCell.h"

@interface ECGroupNameCell()

@property (nonatomic, weak) UITextField *nameField;

@end

@implementation ECGroupNameCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self buildUI];
    }
    return self;
}

- (NSString *)groupName{
    return self.nameField.text;
}

- (void)setGroupName:(NSString *)groupName{
    self.nameField.text = groupName;
}

- (void)setPlaceholder:(NSString *)placeholder{
    _placeholder = placeholder;
    self.nameField.placeholder = placeholder;
}

- (void)setSecureTextEntry:(BOOL)secureTextEntry{
    _secureTextEntry = secureTextEntry;
    self.nameField.secureTextEntry = secureTextEntry;
}

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField endEditing:YES];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if(self.maxLength && [textField.text stringByAppendingString:string].length > self.maxLength){
        [ECCommonTool toast:@"输入长度超过限制"];
        return NO;
    }
    return YES;
}

- (void)setIsDiscuss:(BOOL)isDiscuss {
    _isDiscuss = isDiscuss;
    self.textLabel.text = isDiscuss?@"讨论组名称":@"群组名称";
}
#pragma mark - 创建UI
- (void)buildUI{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.textLabel.text = @"群组名称";
    UITextField *nameField = [[UITextField alloc] init];
    nameField.returnKeyType = UIReturnKeyDone;
    nameField.font = EC_Font_System(16);
    nameField.textColor = EC_Color_Sec_Text;
    nameField.textAlignment = NSTextAlignmentRight;
    nameField.placeholder = @"请输入";
    nameField.delegate = self;
    nameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.contentView addSubview:nameField];
    self.nameField = nameField;
    EC_WS(self)
    [nameField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.contentView).offset(14);
        make.bottom.equalTo(weakSelf.contentView).offset(-14);
        make.right.equalTo(weakSelf.contentView).offset(-40);
        make.width.offset(200);
    }];
}

@end
