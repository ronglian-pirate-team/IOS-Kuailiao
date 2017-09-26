//
//  ECWebBaseController+SnatchContent.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/24.
//

#import "ECWebBaseController+SnatchContent.h"
#import <objc/runtime.h>
#import <SDWebImage/SDWebImageManager.h>

@implementation ECWebBaseController (SnatchContent)

const char ec_web_SnatchContent_doc;

- (void)setDoc:(TFHpple *)doc {
    objc_setAssociatedObject(self, &ec_web_SnatchContent_doc, doc, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TFHpple *)doc {
    return objc_getAssociatedObject(self, &ec_web_SnatchContent_doc);
}

- (void)ec_parseHtml:(NSString *)urlStr completion:(void (^)(NSDictionary *ec_dict))completion {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    __block NSString *articleTitle = nil;
    __block NSString *content = nil;
    __block NSString *ec_urlStr = urlStr;
    __block NSString *imageStr = nil;
    self.doc = [[TFHpple alloc] initWithHTMLData:[NSData dataWithContentsOfURL:[NSURL URLWithString:ec_urlStr]]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *titleArray = [self.doc searchWithXPathQuery:@"//title"];
        for (TFHppleElement *element in titleArray) {
            NSString *articleTitle = element.text?element.text:@"网页";
            articleTitle = [[[articleTitle stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\t" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
            articleTitle = [articleTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        if (![ec_urlStr containsString:@"taobao.com"]) {
            NSArray *descArray = [self.doc searchWithXPathQuery:@"//meta"];
            for (TFHppleElement *element in descArray) {
                if ([[element objectForKey:@"name"] isEqualToString:@"description"]) {
                    content = [element.attributes objectForKey:@"content"]?:@"";
                }
            }
        }
        if (content.length<=0) {
            NSRange range1;
            ec_urlStr = [ec_urlStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([ec_urlStr hasPrefix:@"http://"]) {
                range1 = [ec_urlStr rangeOfString:@"http://"];
            } else if ([ec_urlStr hasPrefix:@"https://"]) {
                range1 = [ec_urlStr rangeOfString:@"https://"];
            }
            NSRange range2 = [ec_urlStr rangeOfString:@".com"];
            if (range1.length>0) {
                NSRange range3 = [[ec_urlStr substringFromIndex:range1.length] rangeOfString:@":"];
                range3.location+=range1.length-1;
                NSRange range4 = [[ec_urlStr substringFromIndex:range1.length] rangeOfString:@"/"];
                range4.location+=range1.length-1;
                range3 = range3.length==0?range4:range3;
                NSRange range = range2.length==0?range3:range2;
                if (range.length>0) {
                    content = [ec_urlStr substringWithRange:NSMakeRange(range1.location+range1.length, range.location+range.length-range1.length)]?:@"";
                }
            }
        }
        NSArray *imgArray = [self.doc searchWithXPathQuery:@"//img"];
        [imgArray enumerateObjectsUsingBlock:^(TFHppleElement *element, NSUInteger idx, BOOL *stop) {
            if ([[element objectForKey:@"class"] isEqualToString:@"firstPreload"]) {
                NSLog(@"img:%@",element.attributes);
                imageStr = [element.attributes objectForKey:@"src"]?:@"";
            }
        }];
        if (imageStr.length<=0&&imgArray.count>0) {
            TFHppleElement *element0 = (TFHppleElement *)imgArray[0];
            TFHppleElement *element = [[TFHppleElement alloc] init];
            if (imgArray.count>1) {
                TFHppleElement *element1 = (TFHppleElement *)imgArray[1];
                element = element1==nil?element0:element1;
            }
            imageStr = [element objectForKey:@"src"];
        }
        [[SDWebImageManager sharedManager].imageDownloader downloadImageWithURL:[NSURL URLWithString:imageStr] options:SDWebImageDownloaderLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            
        } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
            if (!image)
                image = [UIImage imageNamed:@"attachment"];
            NSString *localPath = [self saveImage:image];
            dict[@"url"] = ec_urlStr;
            dict[@"title"] = articleTitle.length==0?@"网页":articleTitle;
            dict[@"content"] = content;
            dict[@"remotePath"] = imageStr;
            dict[@"localpath"] = localPath;
            completion(dict);
        }];
    });
}

- (NSString *)saveImage:(UIImage *)image {
    
    image==nil?[UIImage imageNamed:@"attachment"]:image;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmssSSS";
    NSString *dateStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",dateStr]];
    NSData *imageData = [NSData data];
    imageData = UIImageJPEGRepresentation(image, 0.5);
    [imageData writeToFile:path atomically:YES];
    return path;
}
@end
