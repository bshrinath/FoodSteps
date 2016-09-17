//
//  FeedDetailViewController.m
//  foodsteps1
//
//  Created by Shrinath on 8/1/16.
//  Copyright © 2016 cmu. All rights reserved.
//

#import "FeedDetailViewController.h"
#import "BackgroundLayer.h"
@import Firebase;
@import FirebaseAuth;
@import FirebaseStorage;
@import FirebaseDatabase;

@interface FeedDetailViewController() {
    NSArray *splitter;
}

@end



@implementation FeedDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *yelpRating;
    
    CAGradientLayer *bgLayer = [BackgroundLayer blueGradient];
    bgLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:bgLayer atIndex:0];
    
    FIRUser *user = [FIRAuth auth].currentUser;
    
    if(user!= nil)
    {
        FIRStorage *storage = [FIRStorage storage];
        NSString *refURL = [NSString stringWithFormat:@"gs://foodsteps-cee33.appspot.com/%@/", _userUID];
        
        FIRStorageReference *storageRef = [storage referenceForURL:refURL];
        
        NSString *imagePointer = [NSString stringWithFormat:@"%@.png", _userPostID];
        
        yelpRating = self.placeRating;
        
        FIRStorageReference *foodPic = [storageRef child:imagePointer];
        
        [foodPic downloadURLWithCompletion:^(NSURL *URL, NSError *error){
            if (error != nil) {
                // Handle any errors
            } else {
                NSLog(@"Getting image...");
                UIImage *food = [UIImage imageWithData: [NSData dataWithContentsOfURL:URL]];
                _ImageView.image = food;
                _ImageView.transform = CGAffineTransformMakeRotation(M_PI_2);
                // Get the download URL for 'images/stars.jpg'
            }
        }];
        
        
    }
    
    splitter = [self.currentUserName componentsSeparatedByString:@" "];
    self.nameLabel.text = splitter[0];
    self.placeLabel.text = self.restaurantName;
    self.descLabel.text = self.placeDesc;
    self.ratingLabel.text = self.placeRating;
    self.yelpRatingLabel.text = yelpRating;
    
    [_nameLabel sizeToFit];
    [_placeLabel sizeToFit];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _ImageView.layer.cornerRadius = 10;
    _ImageView.clipsToBounds = YES;
    
    
}

@end
