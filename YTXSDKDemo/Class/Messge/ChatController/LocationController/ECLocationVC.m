//
//  ECLocationVC.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/9.
//
//

#import "ECLocationVC.h"
#import "ECLocationPoint.h"

@interface ECLocationVC ()<ECBaseContollerDelegate, MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource,UIActionSheetDelegate>

@property(nonatomic, strong) MKMapView *mapView;
@property(nonatomic,strong) CLLocationManager *locationManager;
@property(nonatomic,strong) CLGeocoder * geoCoder;
@property(nonatomic,strong) ECLocationPoint *locationPoint;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSIndexPath *selectIndex;
@end

@implementation ECLocationVC

- (void)viewDidLoad {
    self.baseDelegate = self;
    self.dataSource = [NSMutableArray array];
    [super viewDidLoad];
}

#pragma mark - 搜索附近的地点信息
- (void)searchNearbyLocal:(CLLocationCoordinate2D) centerCoordinate{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(centerCoordinate, 1000, 1000);
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc]init];
    request.region = region;
    request.naturalLanguageQuery = @"餐馆";
    MKLocalSearch *localSearch = [[MKLocalSearch alloc]initWithRequest:request];
    EC_WS(self)
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error){
        if (!error) {
            [weakSelf.dataSource removeAllObjects];
            [weakSelf.dataSource addObjectsFromArray:response.mapItems];
            [weakSelf.tableView reloadData];
        }else{
        }
    }];
}

#pragma mark - Location Service 配置
- (void)configLocationService{
    _geoCoder = [[CLGeocoder alloc] init];
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    if ([CLLocationManager locationServicesEnabled]) {
        if ([UIDevice currentDevice].systemVersion.integerValue>=8.0) {
            [_locationManager requestAlwaysAuthorization];
        }
        CLAuthorizationStatus status = CLLocationManager.authorizationStatus;
        if (status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied) {
            [ECCommonTool toast:@"请在设置-隐私里允许程序使用地理位置服务"];
        } else {
            if (self.locationPoint) {
                [self setRegion:self.locationPoint.coordinate];
                [self reverseGeoLocation:self.locationPoint.coordinate];
                [self searchNearbyLocal:self.locationPoint.coordinate];
                [_mapView selectAnnotation:self.locationPoint animated:YES];
            } else {
                self.mapView.showsUserLocation = YES;
            }
        }
    }else{
        [ECCommonTool toast:@"请打开地理位置服务"];
    }
}

#pragma mark - 设置地图区域
- (void)setRegion:(CLLocationCoordinate2D)coordinate {
    MKCoordinateRegion theRegion;
    theRegion.center = coordinate;
    theRegion.span.longitudeDelta = 0.01f;
    theRegion.span.latitudeDelta = 0.01f;
    [_mapView setRegion:theRegion animated:NO];
}

#pragma mark - reverseGeoLocation
- (void)reverseGeoLocation:(CLLocationCoordinate2D)locationCoordinate2D{
    if (self.geoCoder.isGeocoding) {
        [self.geoCoder cancelGeocode];
    }
    CLLocation *location = [[CLLocation alloc] initWithLatitude:locationCoordinate2D.latitude longitude:locationCoordinate2D.longitude];
    __weak typeof(self) weakSelf = self;
    [self.geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error == nil) {
            CLPlacemark *mark = [placemarks firstObject];
            NSString * title  = mark.name;
            ECLocationPoint *ponit = [[ECLocationPoint alloc] initWithCoordinate:locationCoordinate2D andTitle:title];
            weakSelf.locationPoint = ponit;
            [weakSelf.mapView removeAnnotations:weakSelf.mapView.annotations];
            [weakSelf.mapView addAnnotation:ponit];
        } else {
        }
    }];
}

#pragma mark - 导航
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex==0) {
        MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:self.locationPoint.coordinate addressDictionary:@{@"title":self.locationPoint.title}];
        MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:placemark];
        toLocation.name = self.locationPoint.title;
        
        [MKMapItem openMapsWithItems:@[currentLocation, toLocation]
                       launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking,MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]}];
    }
}

#pragma mark - tableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UITableViewCell *selectCell = [tableView cellForRowAtIndexPath:self.selectIndex];
    selectCell.accessoryType = UITableViewCellAccessoryNone;
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    self.selectIndex = indexPath;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ECLocation_Cell"];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ECLocation_Cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    MKMapItem *mapItem = self.dataSource[indexPath.row];
    cell.textLabel.text = mapItem.name;
    cell.detailTextLabel.text = mapItem.placemark.addressDictionary[@"FormattedAddressLines"][0];
    if(indexPath.row == 0){
        self.selectIndex = indexPath;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else
        cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

#pragma mark - ECBaseContoller delegate
- (ECBaseItemBlock)baseController:(ECBaseContoller *)baseVC configRightBtnItemWithStr:(NSString **)str {
    *str = NSLocalizedString(@"确定", nil);
    EC_WS(self);
    return ^id {
        if ([weakSelf.dataSource objectAtIndexCheck:self.selectIndex.row]) {
            UIImage *shotImg = [UIImage ec_screenshotWithView:self.mapView];
            if (weakSelf.baseTwoObjectCompletion)
                weakSelf.baseTwoObjectCompletion(weakSelf.dataSource[self.selectIndex.row],shotImg);
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }
        return nil;
    };
}

- (ECBaseItemBlock)baseController:(ECBaseContoller *)baseVC configLeftBtnItemWithStr:(NSString **)str{
    *str = NSLocalizedString(@"取消", nil);
    EC_WS(self)
    return ^id{
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
        return nil;
    };
}

#pragma mark - MKMapView delegate
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    CLLocationCoordinate2D centerCoordinate = mapView.region.center;
    [self reverseGeoLocation:centerCoordinate];
    [self searchNearbyLocal:centerCoordinate];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    [self setRegion:userLocation.coordinate];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{
    static NSString *reusePin = @"PinAnnotation";
    MKPinAnnotationView * pin = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:reusePin];
    if (!pin) {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reusePin];
    }
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"location_GPS"] forState:UIControlStateNormal];
    [button sizeToFit];
    pin.rightCalloutAccessoryView = button;
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = self.locationPoint.title;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont systemFontOfSize:12.0f];
    [titleLabel sizeToFit];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    pin.detailCalloutAccessoryView = titleLabel;
    
    pin.canShowCallout    = YES;
    pin.animatesDrop = YES;
    pin.selected = YES;
    return pin;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views{
    [self.mapView addAnnotation:self.locationPoint];
    [_mapView selectAnnotation:self.locationPoint animated:YES];
    UIView * view = [mapView viewForAnnotation:self.mapView.userLocation];
    view.hidden = YES;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    UIActionSheet *action = [[UIActionSheet alloc] init];
    [action addButtonWithTitle:@"苹果地图导航"];
    [action addButtonWithTitle:@"取消"];
    action.delegate = self;
    action.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [action showInView:self.view];
}
#pragma mark - UI创建
- (void)buildUI{
    if ([self.basePushData isKindOfClass:[ECLocationPoint class]])
        self.locationPoint = self.basePushData;
    self.title = NSLocalizedString(@"位置", nil);
    [self.view addSubview:self.mapView];
    [self.view addSubview:self.tableView];
    EC_WS(self)
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(weakSelf.view);
        make.bottom.equalTo(weakSelf.view).offset(-weakSelf.view.ec_height / 2);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.mapView.mas_bottom);
    }];
    [self configLocationService];
    [super buildUI];
}

- (MKMapView *)mapView{
    if(!_mapView){
        _mapView = [[MKMapView alloc] init];
        _mapView.delegate = self;
    }
    return _mapView;
}

- (UITableView *)tableView{
    if(!_tableView){
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

@end
