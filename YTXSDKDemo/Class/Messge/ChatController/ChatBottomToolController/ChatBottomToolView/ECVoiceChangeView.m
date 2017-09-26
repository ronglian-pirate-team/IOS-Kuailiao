//
//  ECVoiceChangeView.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/5.
//
//

#import "ECVoiceChangeView.h"
#import "ECVoiceChangeCell.h"
#import <AVFoundation/AVFoundation.h>

#define EC_BTN_H 40

@interface ECVoiceChangeView()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSIndexPath *selectIndex;
@property (nonatomic, strong) ECVoiceMessageBody *changeVoiceMessageBody;

@end

@implementation ECVoiceChangeView

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        self.backgroundColor = EC_Color_White;
        self.dataArray = @[@{@"title":@"原声", @"image": @"chatIconYuyinNormal"}, @{@"title":@"萝莉", @"image": @"voiceChange_1"}, @{@"title":@"大叔", @"image": @"voiceChange_2"}, @{@"title":@"惊悚", @"image": @"voiceChange_3"}, @{@"title":@"搞怪", @"image": @"voiceChange_4"}, @{@"title":@"空灵", @"image": @"voiceChange_5"}];
        [self buildUI];
    }
    return self;
}

- (void)cancelAction{
    self.messageBody = nil;
    [self removeFromSuperview];
}

- (void)sendAction{
    if(self.changeVoiceMessageBody){
        [[ECDeviceHelper sharedInstanced] ec_sendMessage:self.changeVoiceMessageBody to:self.receiver];
    }else{
        [[ECDeviceHelper sharedInstanced] ec_sendMessage:self.messageBody to:self.receiver];
    }
    self.messageBody = nil;
    self.changeVoiceMessageBody = nil;
    [self removeFromSuperview];
}

- (ECSountTouchConfig *)voiceConfigSet:(NSInteger)index{
    ECSountTouchConfig *config = [[ECSountTouchConfig alloc] init];
    switch (self.selectIndex.row) {
        case 0:
            break;
        case 1:
            config.pitch = 8;
            break;
        case 2:
            config.pitch = -4;
            config.rate = -10;
            break;
        case 3:
            config.tempoChange = 0;
            config.pitch = 0;
            config.rate = -20;
            break;
        case 4:
            config.rate = 100;
            break;
        case 5:
            config.tempoChange = 20;
            config.pitch = 0;
            break;
        default:
            break;
    }
    return config;
}

- (void)changeVoice:(ECSountTouchConfig *)config{
    [[ECDevice sharedInstance].messageManager stopPlayingVoiceMessage];
    NSString *srcFile = ((ECFileMessageBody *)self.messageBody).localPath;
    NSString *fileName = [NSString stringWithFormat:@"voiceFile%lld.amr",(long long)[NSDate timeIntervalSinceReferenceDate]];
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dstFile = [cacheDir stringByAppendingPathComponent:fileName];
    BOOL isExist =  [[NSFileManager defaultManager]fileExistsAtPath:dstFile];
    if (isExist) {
        NSError *err = nil;
        [[NSFileManager defaultManager]removeItemAtPath:dstFile error:&err];
    }
    config.srcVoice = srcFile;
    config.dstVoice = dstFile;
    [[ECDevice sharedInstance].messageManager changeVoiceWithSoundConfig:config completion:^(ECError *error, ECSountTouchConfig* dstSoundConfig) {
        if (error.errorCode == ECErrorType_NoError) {
            self.changeVoiceMessageBody = [[ECVoiceMessageBody alloc] initWithFile:[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[dstSoundConfig.dstVoice lastPathComponent]] displayName:[dstSoundConfig.dstVoice lastPathComponent]];
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
            [[ECDevice sharedInstance].messageManager playVoiceMessage:self.changeVoiceMessageBody completion:^(ECError *error) {
                if(error.errorCode == ECErrorType_NoError){
                    EC_Demo_AppLog(@"播放变声");
                }else{
                    EC_Demo_AppLog(@"%ld===%@", error.errorCode, error.errorDescription);
                }
            }];
        }
    }];
}

#pragma mark - UICollectionView delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(self.selectIndex){
        ECVoiceChangeCell *cell = (ECVoiceChangeCell *)[collectionView cellForItemAtIndexPath:self.selectIndex];
        cell.isSelected = NO;
    }
    ECVoiceChangeCell *cell = (ECVoiceChangeCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.isSelected = YES;
    self.selectIndex = indexPath;
    [self changeVoice:[self voiceConfigSet:indexPath.row]];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ECVoiceChangeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ECVoiceChange_Cell" forIndexPath:indexPath];
    cell.infoDic = self.dataArray[indexPath.row];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

#pragma mark - UI创建
- (void)buildUI{
    self.backgroundColor = EC_Color_White;
    [self addSubview:self.collectionView];
    EC_WS(self)
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(weakSelf);
        make.bottom.equalTo(weakSelf).offset(-EC_BTN_H);
    }];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(0, self.ec_height - EC_BTN_H, EC_kScreenW / 2, EC_BTN_H);
    [cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [self addSubview:cancelBtn];
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sendBtn.frame = CGRectMake(EC_kScreenW / 2, self.ec_height - EC_BTN_H, EC_kScreenW / 2, EC_BTN_H);
    [sendBtn addTarget:self action:@selector(sendAction) forControlEvents:UIControlEventTouchUpInside];
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [self addSubview:sendBtn];
    cancelBtn.backgroundColor = EC_Color_VCbg;
    sendBtn.backgroundColor = EC_Color_VCbg;
    [cancelBtn setTitleColor:EC_Color_App_Main forState:UIControlStateNormal];
    [sendBtn setTitleColor:EC_Color_App_Main forState:UIControlStateNormal];
}

- (UICollectionView *)collectionView{
    if(!_collectionView){
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        layout.itemSize = CGSizeMake(EC_kScreenW / 4, 87);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, EC_kScreenW, 174) collectionViewLayout:layout];
        _collectionView.backgroundColor = EC_Color_White;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[ECVoiceChangeCell class] forCellWithReuseIdentifier:@"ECVoiceChange_Cell"];
    }
    return _collectionView;
}

@end
