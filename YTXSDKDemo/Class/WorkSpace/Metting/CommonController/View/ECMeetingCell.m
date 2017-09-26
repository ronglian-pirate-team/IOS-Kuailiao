//
//  ECMeetingCell.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/17.
//
//

#import "ECMeetingCell.h"

@interface ECMeetingCell()

@property (nonatomic, strong) UIImageView *lockImage;

@end

@implementation ECMeetingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier]){
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.textLabel.font = EC_Font_System(16);
        self.textLabel.textColor = EC_Color_Black;
        self.detailTextLabel.font = EC_Font_System(12);
        self.detailTextLabel.textColor = EC_Color_Sec_Text;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.lockImage];
        EC_WS(self)
        [self.lockImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.textLabel);
            make.left.equalTo(weakSelf.textLabel.mas_right).offset(10);
        }];
    }
    return  self;
}

- (void)setMeetingRoom:(ECMultiVoiceMeetingRoom *)meetingRoom{
    _meetingRoom = meetingRoom;
    NSString *name;
    if (meetingRoom.roomName.length>0) {
        name = meetingRoom.roomName;
    } else {
        name = [NSString stringWithFormat:@"%@房间", (meetingRoom.roomNo.length>4?[meetingRoom.roomNo substringFromIndex:(meetingRoom.roomNo.length-4)]:meetingRoom.roomNo)];
    }
    self.textLabel.text = name;
    NSString *info = nil;
    if (meetingRoom.square == meetingRoom.joinNum) {
        info = [NSString stringWithFormat:@"%d人加入(已满)", (int)meetingRoom.joinNum];
    } else {
        info = [NSString stringWithFormat:@"%d人加入", (int)meetingRoom.joinNum];
    }
    self.lockImage.hidden = !meetingRoom.isValidate;
//    NSUInteger fromIndex = meetingRoom.creator.length>4?(meetingRoom.creator.length-4):0;
    self.detailTextLabel.text = [NSString stringWithFormat:@"%@,由%@创建", info, meetingRoom.creator];
}

- (void)setInterphoneMeetingMsg:(ECInterphoneMeetingMsg *)interphoneMeetingMsg{
    _interphoneMeetingMsg = interphoneMeetingMsg;
    self.detailTextLabel.text = @"";
    self.textLabel.text = [NSString stringWithFormat:@"由%@创建", interphoneMeetingMsg.fromVoip];
    self.lockImage.hidden = YES;
}

- (UIImageView *)lockImage{
    if(!_lockImage){
        _lockImage = [[UIImageView alloc] init];
        _lockImage.image = EC_Image_Named(@"registIconPassword");
    }
    return _lockImage;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if(self.meetingRoom){
        self.textLabel.ec_y = 15;
        self.detailTextLabel.ec_y = CGRectGetMaxY(self.textLabel.frame) + 9;
    }else if (self.interphoneMeetingMsg){
        self.textLabel.ec_y = 25;
    }
}

@end
