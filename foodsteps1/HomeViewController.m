//
//  HomeViewController.m
//  foodsteps1
//
//  Created by Lakshmi Subramanian on 7/27/16.
//  Copyright © 2016 cmu. All rights reserved.

//References : https://www.youtube.com/watch?v=ACeWcKEwqMU "custom mapkit annotations"
////

#import <Foundation/Foundation.h>
#import "HomeViewController.h"
#import "Post.h"
#import <UIKit/UIKit.h>
#import "BackgroundLayer.h"
#import "FBSDKCoreKit/FBSDKCoreKit.h"
#import "FBSDKLoginKit/FBSDKLoginKit.h"
#import "FBSDKCoreKit/FBSDKGraphRequest.h"
#import "MapPin.h"
@import Firebase;
@import FirebaseAuth;
@import FirebaseStorage;
@import FirebaseDatabase;

@interface HomeViewController () {
    
    __weak IBOutlet MKMapView *mapView;
    __weak IBOutlet UIImageView *ProfilePic;
    __weak IBOutlet UILabel *fbEmail;
    __weak IBOutlet UILabel *fbFirstName;
    __weak IBOutlet UIButton *logOut;
    NSUserDefaults *defaults;
    NSString *fbID;
    NSString *userCurrentID;
    NSString *address;
    CLLocationManager *locationManager;
    NSMutableArray *locations;
}

@property (strong, nonatomic) CLGeocoder *geoCoder;
@property (strong, nonatomic) CLPlacemark *placeMark;
@property (strong, nonatomic) CLLocation *nLoc;
@property (strong, nonatomic) Post *post;

@end

@implementation HomeViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    
    locations = [[NSMutableArray alloc] init];
    
    NSLog(@"Hello");
    ProfilePic.layer.cornerRadius = ProfilePic.frame.size.width/2;
    ProfilePic.clipsToBounds = true;
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager requestLocation];
    [locationManager requestWhenInUseAuthorization];
    [locationManager startUpdatingLocation];
    
    _geoCoder = [[CLGeocoder alloc] init];
    
    mapView.clipsToBounds = true;
    
    FIRUser *user = [FIRAuth auth].currentUser;
            
    if (user != nil)
    {
                fbFirstName.text = user.displayName;
                fbEmail.text = user.email;
                NSURL *photoUrl = user.photoURL;
                NSData *data = [NSData dataWithContentsOfURL:photoUrl];
                ProfilePic.image = [UIImage imageWithData:data];
                FIRStorage *storage = [FIRStorage storage];
                FIRStorageReference *storageRef = [storage referenceForURL:@"gs://foodsteps-cee33.appspot.com"];

        
        NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"fb_token"];
        
        
        FBSDKGraphRequest *profPic = [[FBSDKGraphRequest alloc]
                                    initWithGraphPath:@"me?fields=picture.width(300).height(300).redirect(false)"
                                      parameters:nil
                                      tokenString: access_token
                                      version:nil
                                      HTTPMethod:@"GET"];
        
        [profPic startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                              id result,
                                              NSError *error) {
            
            if(error == nil)
            {
                NSLog(@"%@", result);
                NSDictionary *dictionary = (NSDictionary *)result;
                fbID = [dictionary objectForKey:@"id"];
                NSDictionary *pic = [dictionary objectForKey:@"picture"];
                NSDictionary *data = [pic objectForKey:@"data"];
                NSString *urlString = (NSString *)[data objectForKey:@"url"];
                
                NSURL *url = [NSURL URLWithString:urlString];
                
                NSLog(@"%@", url);
                
                NSData *imageData = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
                
                NSString *uploadPath = [fbID stringByAppendingString:@"/profile_pic.jpg"];
                
                if(imageData)
                {
                    FIRStorageReference *profilePicReference = [storageRef child:uploadPath ];
                    
                    FIRStorageUploadTask *uploadTask = [profilePicReference putData:imageData metadata:nil completion:^(FIRStorageMetadata *metadata, NSError *error) {
                        if (error != nil) {
                            NSLog(@"Error downloading!");
                        } else {
                            // Metadata contains file metadata such as size, content-type, and download URL.
                            
                        }
                        
                    }];
                    ProfilePic.image = [UIImage imageWithData:imageData];
                    ProfilePic.layer.cornerRadius = ProfilePic.frame.size.width/2;
                    ProfilePic.clipsToBounds = true;
                }
            }
            
            else {
                NSLog(@"%@", error);
            }
            // Handle the result
        }];
    
                // The user's ID, unique to the Firebase
                // project. Do NOT use this value to
                // authenticate with your backend server, if
                // you have one. Use
                //getTokenWithCompletion:completion: instead.
        
    }
    
    else {
        
        }
    
    _ref = [[FIRDatabase database] reference];
    
    self.post = [[Post alloc] init];
    
    _postID = [[NSMutableArray alloc] init];
    _userIDArray = [[NSMutableArray alloc] init];
    _desc = [[NSMutableArray alloc] init];
    _ratings = [[NSMutableArray alloc] init];
    _placeName = [[NSMutableArray alloc] init];
    _addressArray = [[NSMutableArray alloc] init];
    _addressLine1 = [[NSMutableArray alloc] init];
    _addressLine2 = [[NSMutableArray alloc] init];
    _userEmail = [[NSMutableArray alloc] init];
    _userName = [[NSMutableArray alloc] init];
    
    NSMutableArray *tempDict = [[NSMutableArray alloc] init];
    
    NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"fb_token"];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_sync(queue, ^{
        //Do something else
        
        __block NSString *currentID;
        
        FBSDKGraphRequest *idRequest = [[FBSDKGraphRequest alloc]
                                        initWithGraphPath:@"me"
                                        parameters:@{@"fields": @"id"}
                                        tokenString: access_token
                                        version:nil
                                        HTTPMethod:@"GET"];
        
        [idRequest startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                                id result,
                                                NSError *error) {
            
            if(error == nil)
                
            {
                NSDictionary *dictID = (NSDictionary *) result;
                [tempDict addObject:[dictID objectForKey:@"id"]];
                //NSLog(@"The current user ID is: %@", tempDict[0]);
                currentID = tempDict[0];
                userCurrentID = currentID;
            }
            
            [self fetchData];
        }];
    });
    
}

-(void) viewWillAppear:(BOOL)animated {
    
    CAGradientLayer *bgLayer = [BackgroundLayer blueGradient];
    bgLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:bgLayer atIndex:0];
    
    [[logOut layer] setBorderWidth:2.0f];
    [[logOut layer] setBorderColor:[UIColor whiteColor].CGColor];
    logOut.layer.cornerRadius = 10; // this value vary as per your desire
    logOut.clipsToBounds = YES;
    
    FIRUser *user = [FIRAuth auth].currentUser;
    
    if (user != nil)
    {

        NSURL *photoUrl = user.photoURL;
        NSString *userID = user.uid;
        
        
        FIRStorage *storage = [FIRStorage storage];
        FIRStorageReference *storageRef = [storage referenceForURL:@"gs://foodsteps-cee33.appspot.com"];
        
        NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"fb_token"];
        
        
        //NSLog(@"The current user ID is: %@", tempDict[0]);
        
        
        FBSDKGraphRequest *friendList = [[FBSDKGraphRequest alloc]
                                         initWithGraphPath:@"me?fields=friends"
                                         parameters:nil
                                         tokenString: access_token
                                         version:nil
                                         HTTPMethod:@"GET"];
        
        [friendList startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                                 id result,
                                                 NSError *error) {
            
            if(error == nil)
            {
                //NSLog(@"%@", result);
                NSDictionary *dictionary = (NSDictionary *)result;
                NSDictionary *dict = [dictionary objectForKey:@"friends"];
                
                _idArray = [[NSMutableArray alloc] init];
                
                for(int i = 0; i < [[dict objectForKey:@"data"] count]; i++) {
                    
                    [_idArray addObject:[[[dict objectForKey:@"data"] objectAtIndex:i] valueForKey:@"id"]];
                }
                
                //NSLog(@"%@", idArray);
            }
            
            else {
                NSLog(@"%@",error);
            }
        }];
        
        
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [locationManager requestLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"error: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *location = [locations firstObject];
    MKCoordinateSpan span = MKCoordinateSpanMake(0.05, 0.05);
    MKCoordinateRegion region = MKCoordinateRegionMake(location.coordinate, span);
    [mapView setRegion:region animated:true];
}


-(void) fetchData {
    
    
    dispatch_queue_t queue2 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_sync(queue2, ^{
        
        _refHandle = [[_ref child:@"users"] observeEventType:FIRDataEventTypeValue
                                                   withBlock:^(FIRDataSnapshot * _Nonnull snapshot)
                      {
                          NSDictionary *postDict = snapshot.value;
                          NSLog(@"%@", postDict);
                          
                          for( NSString *aKey in [postDict allKeys] )
                          {
                              _post.userID = aKey;
                              
                              if(![userCurrentID isEqualToString: _post.userID])
                              {
                                  
                                  NSEnumerator *enumerator = [[postDict valueForKey:_post.userID ]keyEnumerator];
                                  
                                  long keyCount = [[[postDict valueForKey:_post.userID] allKeys] count];
                                  
                                  id key;
                                  
                                  NSString *temp = _post.userID;
                                  
                                  while(key = [enumerator nextObject])
                                  {
                                      //NSLog(@"%@", key);
                                      [_postID addObject:key];
                                      //NSLog(@"%@", postID);
                                  }
                                  
                                  if(keyCount > 1)
                                  {
                                      for(int i=0; i< keyCount; i++)
                                      {
                                          [_userIDArray addObject:temp];
                                      }
                                  }
                                  
                                  else {
                                      [_userIDArray addObject:temp];
                                  }
                              }
                              
                              else
                              {
                                  continue;
                              }
                          }
                          
                          
                          //NSLog(@"userID array: %@", _userIDArray);
                          
                          for(int i=0; i< _postID.count; i++)
                          {
                              
                              [_userName addObject:[[[postDict valueForKey:_userIDArray[i]] valueForKey:_postID[i]] valueForKey:@"name"]];
                              
                              [_placeName addObject:[[[postDict valueForKey:_userIDArray[i]] valueForKey:_postID[i]] valueForKey:@"placeName"]];
                              
                              [_addressLine1 addObject:[[[postDict valueForKey:_userIDArray[i]] valueForKey:_postID[i]] valueForKey:@"addressLine1"]];
                              
                              [_addressLine2 addObject:[[[postDict valueForKey:_userIDArray[i]] valueForKey:_postID[i]] valueForKey:@"addressLine2"]];
                              
                              [_ratings addObject:[[[postDict valueForKey:_userIDArray[i]] valueForKey:_postID[i]] valueForKey:@"rating"]];
                              
                              [_desc addObject:[[[postDict valueForKey:_userIDArray[i]] valueForKey:_postID[i]] valueForKey:@"description"]];
                              
                              if([[[postDict valueForKey:_userIDArray[i]] valueForKey:_postID[i]] valueForKey:@"email"])
                              {
                              [_userEmail addObject:[[[postDict valueForKey:_userIDArray[i]] valueForKey:_postID[i]] valueForKey:@"email"]];
                              }
                              
                              address = [_addressLine1[i] stringByAppendingString:@", "];
                              
                              address = [address stringByAppendingString:_addressLine2[i]];
                              
                              [_addressArray addObject: address];
                              
                              address = nil;
                              
                          }
                          
                          
                          NSLog(@"Address Array is %@", _addressArray);
                          
                          
                          /*
                          
                          NSMutableArray* annotations = [[NSMutableArray alloc] init];
                          
                          for (int i = 0; i < _addressArray.count; i++)
                          {
                              MKPointAnnotation* marker = [[MKPointAnnotation alloc] init];
                              
                              marker.title = _addressLine1[i];
                              marker.subtitle = _addressLine2[i];
                              [annotations addObject:marker];
                              NSLog(@"%@", annotations);
                          }
                          
                          [mapView addAnnotations:annotations];
                           */
                          
                          for(int i= 0; i< _addressArray.count; i++)
                          {
                          
                          _geoCoder = [[CLGeocoder alloc] init];
                          [_geoCoder geocodeAddressString:_addressArray[i]
                                       completionHandler:^(NSArray* placemarks, NSError* error){
                                           // Check for returned placemarks
                                           if (placemarks && placemarks.count > 0) {
                                               CLPlacemark *topResult = [placemarks objectAtIndex:0];
                                            
                                               MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:topResult];
                                               //placemark.title = _placeName[i];
                                               //placemark.subtitle = _addressArray[i];
                                               
                                               MKPointAnnotation *annotation = [MKPointAnnotation new];
                                               
                                               annotation.coordinate = placemark.coordinate;
                                               annotation.title = _placeName[i];
                                               annotation.subtitle = _addressArray[i];
                                               
                                               [mapView addAnnotation:annotation];
                                               MKCoordinateSpan span = MKCoordinateSpanMake(0.05, 0.05);
                                               MKCoordinateRegion region = MKCoordinateRegionMake(placemark.coordinate, span);
                                               [mapView setRegion:region animated:true];
                                               
                                               /*
                                               
                                               NSMutableArray* annotations = [[NSMutableArray alloc] init];
                                               
                                               MKPointAnnotation* marker = [[MKPointAnnotation alloc] init];
                                               
                                               marker.title = [placemarks objectAtIndex:0];
                                               marker.subtitle = _addressArray[0];
                                               
                                               //NSLog(@"Placemark name --> %@", placemark.name);
                                               
                                               [annotations addObject:marker];
                                               [mapView addAnnotations:annotations];
                                               */
                                               //[placemark release];
                                           }
                                           //[_geoCoder release];
                                       }];
                          }
                          
                          
                          //NSLog(@"User email is: %@", _userName);
                          
                          
                          
                      }];
    });
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[_ref child:@"users"] removeObserverWithHandle:_refHandle];
    
    /*
     _postID = [[NSMutableArray alloc] init];
     _userIDArray = [[NSMutableArray alloc] init];
     _desc = [[NSMutableArray alloc] init];
     _ratings = [[NSMutableArray alloc] init];
     _placeName = [[NSMutableArray alloc] init];
     _addressLine1 = [[NSMutableArray alloc] init];
     _addressLine2 = [[NSMutableArray alloc] init];
     _userEmail = [[NSMutableArray alloc] init];
     _userName = [[NSMutableArray alloc] init];
     */
    // [tempDict removeAllObjects];
}


- (IBAction)didTapLogout:(id)sender {
    
    NSError *error;
    [[FIRAuth auth] signOut:&error];
    if (!error) {
        // Sign-out succeeded
    }
    
    [FBSDKAccessToken setCurrentAccessToken:nil];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"FirstViewController"];
    
    [self presentViewController:vc animated:YES completion:nil];
    
}

@end
