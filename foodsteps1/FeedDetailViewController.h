//
//  FeedDetailViewController.h
//  foodsteps1
//
//  Created by Shrinath on 8/1/16.
//  Copyright © 2016 cmu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedDetailViewController : UIViewController

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *placeLabel;
@property (nonatomic, weak) IBOutlet UILabel *descLabel;
@property (nonatomic, weak) IBOutlet UILabel *ratingLabel;
@property (nonatomic, weak) IBOutlet UILabel *yelpRatingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *ImageView;

@property (nonatomic) NSString *placeDesc;
@property (nonatomic) NSString *placeRating;
@property (nonatomic) NSString *restaurantName;
@property (nonatomic) NSString *currentUserName;
@property (nonatomic) NSString *userPostID;
@property (nonatomic) NSString *userUID;

@end
