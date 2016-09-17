//  FirstViewController.m
//  foodsteps1
//
//  Created by Shrinath on 7/22/16.
//  Copyright © 2016 cmu. All rights reserved.

//References : https://www.youtube.com/watch?v=ItdtUN2VcrE (for storing profile pic in firebase)
//             https://www.youtube.com/watch?v=3kKzv8VVgMU (storing realtime data in firebase)
//              https://firebase.google.com/docs/database/ios/save-data (firebase store data )
//

#import "FirstViewController.h"
#import "AppDelegate.h"
#import "FBSDKLoginKit/FBSDKLoginKit.h"
#import "FBSDKCoreKit/FBSDKAccessToken.h"


@interface FirstViewController () {
    NSUserDefaults *defaults;
}

@end

@implementation FirstViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString * storyboardName = @"Main";
    _loginButton = [[FBSDKLoginButton alloc] init];
    _loginButton.hidden = true;
    
    [[FIRAuth auth] addAuthStateDidChangeListener:^(FIRAuth *_Nonnull auth,
                                                    FIRUser *_Nullable user) {
        
        if (user != nil) {
            // User is signed in.
            NSLog(@"Hello!!");
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
            
            UITabBarController *obj=[storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
            self.navigationController.navigationBarHidden=YES;
            [self presentViewController:obj animated:YES completion:nil];
        }
        
        else
        {
            // No user is signed in.
            _loginButton.center = self.view.center;
            _loginButton.readPermissions =
            @[@"public_profile", @"email", @"user_friends"];
            _loginButton.delegate = self;
            [self.view addSubview:_loginButton];
            _loginButton.hidden = false;
        }
    }];
}

- (void)loginButton:(FBSDKLoginButton *)loginButton
didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result
              error:(NSError *)error {
    
    NSLog(@"User Logged in");
    self.loginButton.hidden = true;
    
    [_avSpinner startAnimating];
    
    if(error != nil)
    {
        self.loginButton.hidden = false;
        [_avSpinner stopAnimating];
    }
    
    else if (result.isCancelled)
    {
        self.loginButton.hidden = false;
        [_avSpinner stopAnimating];
    }
    
    else
    {
        FIRAuthCredential *credential = [FIRFacebookAuthProvider
                                         credentialWithAccessToken:[FBSDKAccessToken currentAccessToken]
                                         .tokenString];
        
        [[FIRAuth auth] signInWithCredential:credential
                                  completion:^(FIRUser *user, NSError *error)
        {
            NSLog(@"User logged in to Firebase app..");
            NSString *access_token = [FBSDKAccessToken currentAccessToken].tokenString;
            [[NSUserDefaults standardUserDefaults] setObject:access_token forKey:@"fb_token"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }];
    }
    
    
}

- (void) loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    NSLog(@"User logged out");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
