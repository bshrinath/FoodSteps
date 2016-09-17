//
//  FirstViewController.h
//  foodsteps1
//
//  Created by Shrinath on 7/22/16.
//  Copyright © 2016 cmu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
@import FirebaseAuth;

@interface FirstViewController : UIViewController <FBSDKLoginButtonDelegate>

@property (strong, nonatomic) IBOutlet FBSDKLoginButton *loginButton;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *avSpinner;

@end

