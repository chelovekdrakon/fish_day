//
//  ViewController.m
//  FishDay
//
//  Created by Фёдор Морев on 7/12/19.
//  Copyright © 2019 Фёдор Морев. All rights reserved.
//

#import "MainViewController.h"
#import <CoreLocation/CLLocationManager.h>
#import <GoogleMaps/GoogleMaps.h>

@interface MainViewController () <CLLocationManagerDelegate>
@property(assign, nonatomic) CLLocationCoordinate2D currentPosition;

@property(strong, nonatomic) CLLocationManager *locationManager;

@property(strong, nonatomic) GMSMapView *mapView;
@property(strong, nonatomic) GMSMarker *marker;
@property(strong, nonatomic) GMSCameraPosition *camera;
@end

@implementation MainViewController

- (void)loadView {
    [self initLocationManager];
    
    CLLocation *location = [self.locationManager location];
    self.currentPosition = [location coordinate];
    
    [self initDefaultMap];
    
    if ([CLLocationManager locationServicesEnabled]){
        CLAuthorizationStatus permissionStatus = [CLLocationManager authorizationStatus];
        
         if (permissionStatus == kCLAuthorizationStatusNotDetermined){
            [self.locationManager requestWhenInUseAuthorization];
        } else {
            [self showAlert];
        }
        
    } else {
        [self showAlert];
    }
}

- (void)initLocationManager {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    [self.locationManager startUpdatingLocation];
}

- (void)initDefaultMap {
    CLLocationDegrees latitude = self.currentPosition.latitude;
    CLLocationDegrees longitude = self.currentPosition.longitude;
    
    self.camera = [GMSCameraPosition cameraWithLatitude:latitude
                                              longitude:longitude
                                                   zoom:10];
    
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:self.camera];
    self.mapView.myLocationEnabled = YES;
    self.view = self.mapView;

    self.marker = [[GMSMarker alloc] init];
    self.marker.position = CLLocationCoordinate2DMake(latitude, longitude);
    self.marker.map = self.mapView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"");
    // Do any additional setup after loading the view.
}

- (void)updateMap {
    CLLocationDegrees latitude = self.currentPosition.latitude;
    CLLocationDegrees longitude = self.currentPosition.longitude;
    
    GMSCameraPosition *position = [[GMSCameraPosition alloc] initWithLatitude:latitude
                                                                    longitude:longitude
                                                                         zoom:10];
    
    [self.mapView animateToCameraPosition:position];
}

#pragma mark - <CLLocationManagerDelegate>

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedAlways
        || status == kCLAuthorizationStatusAuthorizedWhenInUse){
        CLLocation *location = [self.locationManager location];
        self.currentPosition = [location coordinate];
        
        [self updateMap];
    }
}

#pragma mark - Utils

- (void)showAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Location Permission Denied"
                                                                   message:@"To re-enable, please go to Settings and turn on Location Service for this app."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* action = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {}];
    
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
