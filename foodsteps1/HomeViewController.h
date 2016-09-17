//
//  FirstViewController.h
//  foodsteps1
//
//  Created by Shrinath on 7/22/16.
//  Copyright © 2016 cmu. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MapKit;
@import FirebaseAuth;
@import FirebaseDatabase;

@protocol HandleMapSearch <NSObject>
- (void)dropPinZoomIn:(MKPlacemark *)placemark;
@end

@interface HomeViewController : UIViewController <CLLocationManagerDelegate, HandleMapSearch, MKMapViewDelegate>

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (nonatomic) FIRDatabaseHandle refHandle;

@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) NSArray *fbID;

@property (nonatomic) NSMutableArray *idArray;

@property (nonatomic) NSMutableDictionary *postDict;
@property (nonatomic) NSMutableDictionary *idDict;

@property (nonatomic) NSMutableArray *idArr;

@property (nonatomic) NSMutableArray *postID;
@property (nonatomic) NSMutableArray *userIDArray;
@property (nonatomic) NSMutableArray *desc;
@property (nonatomic) NSMutableArray *addressArray;
@property (nonatomic) NSMutableArray *ratings;
@property (nonatomic) NSMutableArray *placeName;
@property (nonatomic) NSMutableArray *addressLine1;
@property (nonatomic) NSMutableArray *addressLine2;
@property (nonatomic) NSMutableArray *userEmail;
@property (nonatomic) NSMutableArray *userName;

@end
