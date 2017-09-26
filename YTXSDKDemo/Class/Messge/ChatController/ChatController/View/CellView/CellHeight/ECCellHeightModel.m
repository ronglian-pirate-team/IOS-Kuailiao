//
//  ECCellHeightModel.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/28.
//

#import "ECCellHeightModel.h"
#import "ECMessage+ECUtil.h"
#import "ECChatCellUtil.h"
#import "ECMessage+RedpacketMessage.h"
#import "ECChatCellMacros.h"

@implementation ECCellHeightModel
+ (ECMessage *)ec_caculateCellSizeWithMessage:(ECMessage *)message {
    CGSize ec_cellSize = CGSizeZero;
    CGFloat height = 43.0f;
    CGFloat width = 100.0f;
    NSInteger fileType = [ECMessage ExtendTypeOfTextMessage:message];
    switch (fileType) {
        case MessageBodyType_None: {
            if ([message.messageBody isKindOfClass:[ECRevokeMessageBody class]]) {
                ECRevokeMessageBody *revokeBody = (ECRevokeMessageBody *)message.messageBody;
                NSString *content = revokeBody.text;
                CGSize bubbleSize = [content boundingRectWithSize:EC_CHAT_TEXTCELL_BubbleMaxSize options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:EC_Font_System(12.0f)} context:nil].size;
                height = bubbleSize.height + EC_CHAT_REVOKECELL_TOPMARGIN * 2 + EC_CHAT_CELL_V_OtherCell;
                width = bubbleSize.width + EC_CHAT_REVOKECELL_HORMARGIN * 2;
            }
        }
            break;
        case MessageBodyType_Text:
        case MessageBodyType_Call: {
            NSString *content = @"";
            if ([message.messageBody isKindOfClass:[ECTextMessageBody class]]) {
                ECTextMessageBody *body = (ECTextMessageBody *)message.messageBody;
                content = body.text;
            } else if ([message.messageBody isKindOfClass:[ECCallMessageBody class]]) {
                ECCallMessageBody *body = (ECCallMessageBody *)message.messageBody;
                content = body.callText;
            }
            CGSize bubbleSize = [content boundingRectWithSize:EC_CHAT_TEXTCELL_BubbleMaxSize options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:EC_Font_System(EC_CHAT_TEXTCELL_FONT)} context:nil].size;
            height = bubbleSize.height;
            width = bubbleSize.width + EC_CHAT_TEXTCELL_H_MARGIN;
            height = height + EC_CHAT_CELL_V_Other + EC_CHAT_TEXTCELL_H_TOPMARGIN * 2;
            width = width + EC_CHAT_CELL_H_Other;
            
        }
            break;
        case EC_Demo_CAHT_MESSAGE_CUSTOMTYPE_FIREMESSAGE:
        case MessageBodyType_Image: {
            CGSize size = CGSizeMake(EC_CHAT_BASEIMGCELL_H, EC_CHAT_BASEIMGCELL_H);
            CGFloat newWidth = EC_CHATCELL_IMAGE_V * size.width / size.height;
            if (newWidth > 200) {
                newWidth = 200;
            } else if (newWidth < 70) {
                newWidth = 70;
            }
            width = newWidth + EC_CHAT_CELL_H_Other;
            height = EC_CHATCELL_IMAGE_V + EC_CHAT_CELL_V_Other;
        }
            break;
        case EC_Demo_CAHT_MESSAGE_CUSTOMTYPE_BQMM: {
            width = EC_CHAT_BASEIMGCELL_H + EC_CHAT_CELL_H_Other;
            height = EC_CHAT_BASEIMGCELL_V + EC_CHAT_CELL_V_Other;
        }
            break;
        case MessageBodyType_Location: {
            width = EC_CHATCELL_LOCATION_H + EC_CHAT_CELL_H_Other;
            height = EC_CHATCELL_LOCATION_V + EC_CHAT_CELL_V_Other;
        }
            break;
        case MessageBodyType_Preview: {
            width = EC_CHATCELL_PREVIEW_H + EC_CHAT_CELL_H_Other;
            height = EC_CHATCELL_PREVIEW_V + EC_CHAT_CELL_V_Other;

        }
            break;
        case MessageBodyType_Voice: {
            if ([message.messageBody isKindOfClass:[ECVoiceMessageBody class]]) {
                ECVoiceMessageBody *body = (ECVoiceMessageBody *)message.messageBody;
                if ([[NSFileManager defaultManager] fileExistsAtPath:body.localPath] && (body.mediaDownloadStatus==ECMediaDownloadSuccessed || message.messageState != ECMessageState_Receive)) {
                    unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:body.localPath error:nil] fileSize];
                    body.duration = (int)(fileSize/650);
                    if (body.duration == 0) {
                        body.duration = 1;
                    }
                } else {
                    body.duration = 0;
                }
                CGFloat ec_duration_w = [[ECChatCellUtil sharedInstanced] ec_getVoiceWidthWithTime:body.duration];
                width = ec_duration_w + EC_CHAT_CELL_H_Other;
                height = EC_CHATCELL_VOICE_V + EC_CHAT_CELL_V_Other;
            }
        }
            break;
        case EC_Demo_CAHT_MESSAGE_CUSTOMTYPE_SIGHTVIDEO:
        case MessageBodyType_Video: {
            width = EC_CHATCELL_VIDEO_H + EC_CHAT_CELL_H_Other;
            height = EC_CHATCELL_VIDEO_V + EC_CHAT_CELL_V_Other;
        }
            break;
        case MessageBodyType_File: {
            width = EC_CHATCELL_FILE_H + EC_CHAT_CELL_H_Other;
            height = EC_CHATCELL_FILE_V + EC_CHAT_CELL_V_Other;
        }
            break;
        case EC_Demo_CAHT_MESSAGE_CUSTOMTYPE_Redpacket: {
            width = EC_CHAT_REDPACKETCELL_H + EC_CHAT_CELL_H_Other;
            height = EC_CHAT_REDPACKETCELL_V + EC_CHAT_CELL_V_Other;
        }
            break;
        case EC_Demo_CAHT_MESSAGE_CUSTOMTYPE_RedpacketTakenTip: {
            NSString *content = [message redpacketString];
            CGSize bubbleSize = [content boundingRectWithSize:EC_CHAT_TEXTCELL_BubbleMaxSize options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:EC_Font_System(12.0f)} context:nil].size;
            width = bubbleSize.width + BACKGROUND_LEFT_RIGHT_PADDING * 2 + ICON_LEFT_RIGHT_PADDING + ICON_W;
            height = bubbleSize.height + ICON_TOP_PADDING * 2 + EC_CHAT_CELL_V_OtherCell;
        }
            break;
        default: {
            height = 43.0f + EC_CHAT_CELL_V_Other;
            width = 100.0f + EC_CHAT_CELL_H_Other;
        }
            break;
    }
    
    [[ECMessageDB sharedInstanced] updateMessageSize:message.sessionId messageId:message.messageId withCellSize:CGSizeMake(width, height)];
    message.cellWidth = width;
    message.cellHeight = height;
    ec_cellSize = CGSizeMake(width, height);
    return message;
}

@end
