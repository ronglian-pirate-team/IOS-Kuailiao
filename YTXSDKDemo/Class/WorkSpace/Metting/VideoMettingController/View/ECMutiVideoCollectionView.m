//
//  ECMutiVideosView.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/19.
//
//

#import "ECMutiVideoCollectionView.h"
#import "ECMeetingVideoCell.h"

@interface ECMutiVideoCollectionView()<UICollectionViewDelegate, UICollectionViewDataSource>

@end

@implementation ECMutiVideoCollectionView

- (instancetype)initWithFrame:(CGRect)frame{
    UICollectionViewFlowLayout *curLayout = [[UICollectionViewFlowLayout alloc] init];
    curLayout.minimumLineSpacing = 10;
    curLayout.minimumInteritemSpacing = 10;
    curLayout.itemSize = CGSizeMake(88, 88);
    curLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    curLayout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 12);
    if(self = [super initWithFrame:frame collectionViewLayout:curLayout]){
        self.collectionSource = [NSMutableArray array];
        self.backgroundColor = EC_Color_Clear;
        self.delegate = self;
        self.dataSource = self;
    }
    return self;
}

- (void)setCollectionSource:(NSMutableArray *)collectionSource{
//    _collectionSource = collectionSource;
    if(!_collectionSource)
        _collectionSource = [NSMutableArray array];
    [_collectionSource removeAllObjects];
    for (ECMultiVideoMeetingMember *videoMeetingMember in collectionSource) {
        if(![videoMeetingMember.voipAccount.account isEqualToString:[ECDevicePersonInfo sharedInstanced].userName])
           [_collectionSource addObject:videoMeetingMember];
    }
    for (int i = 0; i < collectionSource.count; i++) {
        ECMultiVideoMeetingMember *videoMeetingMember = collectionSource[i];
        NSString *identifier = [@"ECMutiVideo_Cell" stringByAppendingFormat:@"%@", videoMeetingMember.voipAccount.account];
        [self registerClass:[ECMeetingVideoCell class] forCellWithReuseIdentifier:identifier];
    }
    [self reloadData];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ECMultiVideoMeetingMember *videoMeetingMember = self.collectionSource[indexPath.row];
    NSString *identifier = [@"ECMutiVideo_Cell" stringByAppendingFormat:@"%@", videoMeetingMember.voipAccount.account];
    ECMeetingVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.meetingRoomNum = self.meetingRoomNum;
    cell.videoMeetingMember = videoMeetingMember;
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.collectionSource.count;
}

@end
