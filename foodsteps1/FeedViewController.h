//
//  FeedViewController.h
//  foodsteps1
//
//  Created by Shrinath on 7/30/16.
//  Copyright © 2016 cmu. All rights reserved.
//

#import <UIKit/UIKit.h>
@import FirebaseDatabase;
@import FirebaseAuth;

@class FeedDetailViewController;

@interface FeedViewController : UITableViewController

@property (strong, nonatomic) FeedDetailViewController *detailViewController;

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (nonatomic) FIRDatabaseHandle refHandle; 
@property (nonatomic) NSString *postKey;

@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) NSArray *fbID;

@property (strong, nonatomic) UITextView *textBox;

@property (nonatomic) NSMutableArray *idArray;

@property (nonatomic) NSMutableDictionary *postDict;
@property (nonatomic) NSMutableDictionary *idDict;

@property (nonatomic) NSMutableArray *idArr;

@property (nonatomic) NSMutableArray *postID;
@property (nonatomic) NSMutableArray *userIDArray;
@property (nonatomic) NSMutableArray *desc;
@property (nonatomic) NSMutableArray *ratings;
@property (nonatomic) NSMutableArray *placeName;
@property (nonatomic) NSMutableArray *addressLine1;
@property (nonatomic) NSMutableArray *addressLine2;
@property (nonatomic) NSMutableArray *userEmail;
@property (nonatomic) NSMutableArray *userName;

@end
