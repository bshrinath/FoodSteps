//  FeedViewController.m
//  foodsteps1
//
//  Created by Lakshmi Subramanian on 7/30/16.
//  Copyright © 2016 cmu. All rights reserved.

//References : https://www.youtube.com/watch?v=ZUnUd3A0MzM "data retrival from firebase"
//             https://www.youtube.com/watch?v=tv5c1mZttVE "retrieve children in firebase tableview "
//             https://firebase.google.com/docs/database/ios/retrieve-data "data retrival"
//             http://stackoverflow.com/questions/37611505/retreiving-data-from-firebase-database
//
//

#import "FeedViewController.h"
#import "FeedDetailViewController.h"
#import "Post.h"
#import "BackgroundLayer.h"
#import "FBSDKCoreKit/FBSDKCoreKit.h"
#import "FBSDKLoginKit/FBSDKLoginKit.h"
#import "FBSDKCoreKit/FBSDKGraphRequest.h"
@import Firebase;
@import FirebaseAuth;
@import FirebaseStorage;
@import FirebaseDatabase;

@interface FeedViewController(){
    NSString *userCurrentID;
}

@property (strong, nonatomic) Post *post;

@end

@implementation FeedViewController

-(void) viewDidLoad {
    
    [super viewDidLoad];
    
    CAGradientLayer *bgLayer = [BackgroundLayer blueGradient];
    bgLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:bgLayer atIndex:0];
    
    _ref = [[FIRDatabase database] reference];
    
    self.post = [[Post alloc] init];
    
    _postID = [[NSMutableArray alloc] init];
    _userIDArray = [[NSMutableArray alloc] init];
    _desc = [[NSMutableArray alloc] init];
    _ratings = [[NSMutableArray alloc] init];
    _placeName = [[NSMutableArray alloc] init];
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
                currentID = tempDict[0];
                userCurrentID = currentID;
            }
            
            [self fetchData];
        }];
    });
    
    
    
    
}

-(void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    FIRUser *user = [FIRAuth auth].currentUser;
    
    if (user != nil)
    {
        //fbFirstName.text = user.displayName;
        //fbEmail.text = user.email;
        NSURL *photoUrl = user.photoURL;
        NSString *userID = user.uid;
        //NSString *uploadPath = [userID stringByAppendingString:@"/profile_pic.jpg"];
        //NSData *data = [NSData dataWithContentsOfURL:photoUrl];
        //ProfilePic.image = [UIImage imageWithData:data];
        
        
        FIRStorage *storage = [FIRStorage storage];
        FIRStorageReference *storageRef = [storage referenceForURL:@"gs://foodsteps-cee33.appspot.com"];
        
        NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"fb_token"];

        
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
                
                NSDictionary *dictionary = (NSDictionary *)result;
                NSDictionary *dict = [dictionary objectForKey:@"friends"];
                
                _idArray = [[NSMutableArray alloc] init];
                
                for(int i = 0; i < [[dict objectForKey:@"data"] count]; i++) {
                    
                    [_idArray addObject:[[[dict objectForKey:@"data"] objectAtIndex:i] valueForKey:@"id"]];
                }
                
            }
            
            else {
                NSLog(@"%@",error);
            }
        }];

        
    }
}

-(void) fetchData {
    
    dispatch_queue_t queue2 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_sync(queue2, ^{
    
    _refHandle = [[_ref child:@"users"] observeEventType:FIRDataEventTypeValue
                                               withBlock:^(FIRDataSnapshot * _Nonnull snapshot)
                  {
                      NSDictionary *postDict = snapshot.value;
                      
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
                          }
                      
                      NSLog(@"User email is: %@", _userName);
                      
                      [self.tableView reloadData];
                }];
    });
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[_ref child:@"users"] removeObserverWithHandle:_refHandle];
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _userName.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.frame = CGRectMake(3,
                            3,
                            self.tableView.frame.size.width,
                            cell.frame.size.height);
    
    if([_userName count] && indexPath.row < [_userName count]){
        
    NSLog(@"The usernames are: %ld",[_userName count]);
    
    cell.textLabel.text = [_userName objectAtIndex:indexPath.row];
    NSString *subLabel = [@"was at  " stringByAppendingString: [_placeName objectAtIndex:indexPath.row]];
    
    cell.detailTextLabel.text = subLabel;
    subLabel = nil;
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath


{
    
    if([_userName count] && indexPath.row < [_userName count]){
        
        NSString *rate = [NSString stringWithFormat:@"%@",[_ratings objectAtIndex:indexPath.row]];
        
    self.detailViewController.currentUserName = (NSString *) [_userName objectAtIndex:indexPath.row];
    self.detailViewController.placeDesc = (NSString *) [_desc objectAtIndex:indexPath.row];
    self.detailViewController.placeRating = rate;
    self.detailViewController.restaurantName = (NSString *) [_placeName objectAtIndex:indexPath.row];
    self.detailViewController.userUID = (NSString *) [_userIDArray objectAtIndex:indexPath.row];
    self.detailViewController.userPostID = (NSString *) [_postID objectAtIndex:indexPath.row];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //[self.objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        
        self.detailViewController = [segue destinationViewController];
        
    }
}



@end

