//
//  Post.m
//  foodsteps1
//
//  Created by Shrinath on 7/31/16.
//  Copyright © 2016 cmu. All rights reserved.
//

#import "Post.h"

@implementation Post


- (instancetype)init {
    
    return [self initWithUid:@""
                   andPostid:@""
                 andUsername:@""
                     andDesc:@""
                  andRatings:@""
                andPlacename:@""
             andAddressLine1:@""
             andAddressLine2:@""
                    andEmail:@""];
}

- (instancetype)initWithUid:(NSString *)userID
                andPostid:(NSString *)postID
andUsername: (NSString *)userName
andDesc:(NSString *)desc
andRatings:(NSString *)ratings
andPlacename: (NSString *)placeName
andAddressLine1: (NSString *)addressLine1
andAddressLine2: (NSString *)addressLine2
andEmail: (NSString *)userEmail {
    
    self = [super init];
    if(self) {
        self.userID = userID;
        self.postID = postID;
        self.userName = userName;
        self.desc = desc;
        self.ratings = ratings;
        self.placeName = placeName;
        self.addressLine1 = addressLine1;
        self.addressLine2 = addressLine2;
        self.userEmail = userEmail;
}

    return self;
}

@end
