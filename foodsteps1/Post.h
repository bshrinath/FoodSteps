//
//  Post.h
//  foodsteps1
//
//  Created by Shrinath on 7/31/16.
//  Copyright © 2016 cmu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Post : NSObject

@property (nonatomic) NSMutableDictionary *postDict;
@property (nonatomic) NSMutableDictionary *idDict;
@property (nonatomic) NSMutableArray *idArray;
@property (nonatomic) NSMutableArray *idArr;

@property (nonatomic) NSString *postID;
@property (nonatomic) NSString *userID;
@property (nonatomic) NSString *desc;
@property (nonatomic) NSString *ratings;
@property (nonatomic) NSString *placeName;
@property (nonatomic) NSString *addressLine1;
@property (nonatomic) NSString *addressLine2;
@property (nonatomic) NSString *userEmail;
@property (nonatomic) NSString *userName;

- (instancetype)initWithUid:(NSString *)userID
                  andPostid:(NSString *)postID
                andUsername: (NSString *)userName
                   andDesc:(NSString *)desc
                    andRatings:(NSString *)ratings
               andPlacename: (NSString *)placeName
            andAddressLine1: (NSString *)addressLine1
            andAddressLine2: (NSString *)addressLine2
                   andEmail: (NSString *)userEmail;
@end
