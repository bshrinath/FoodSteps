//
//  FirstViewController.m
//  foodsteps1
//
//  Created by Shrinath on 7/22/16.
//  Copyright © 2016 cmu. All rights reserved.
//

#import "CameraViewController.h"
#import "BackgroundLayer.h"
#import "Social/Social.h"
#import "Accounts/Accounts.h"
#import "FBSDKCoreKit/FBSDKCoreKit.h"
#import "FBSDKLoginKit/FBSDKLoginKit.h"
#import "FBSDKCoreKit/FBSDKGraphRequest.h"
@import FirebaseAuth;
@import FirebaseDatabase;
@import FirebaseStorage;


@interface CameraViewController ()
{
     NSArray *_pickerData;
     NSString *longitude;
     NSString *latitude;
     FIRDatabase *ref;
     NSString *userID;
     NSString *fbID;
     NSString *name;
     NSString *email;
     NSString *placeName;
     NSString *addressLine1;
     NSString *addressLine2;
     NSString *selectedEntry;
     NSString *uploadPath;
}

@end

@implementation CameraViewController
int flag = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    FIRUser *user = [FIRAuth auth].currentUser;
    self.ref = [[FIRDatabase database] reference];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    selectedEntry = @"1";
    
    name = user.displayName;
    email = user.email;
    userID = user.uid;
    
    
    NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"fb_token"];
    
    FBSDKGraphRequest *userDetails = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:@"me"
                                      parameters:@{@"fields":@""}
                                  tokenString: access_token
                                  version:nil
                                  HTTPMethod:@"GET"];
    
    [userDetails startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id result,
                                          NSError *error) {
        
        if(error == nil)
        {
            //NSLog(@"%@", result);
            NSDictionary *dictionary = (NSDictionary *)result;
            fbID = [dictionary objectForKey:@"id"];
            NSLog(@"%@", fbID);
        }
    }];
     
    
    
    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    // Do any additional setup after loading the view, typically from a nib.
    _pickerData = @[@"1", @"2", @"3", @"4", @"5"];
    self->pickerView.dataSource = self;
    self->pickerView.delegate = self;
}

-(void) viewWillAppear:(BOOL)animated {
    
    CAGradientLayer *bgLayer = [BackgroundLayer blueGradient];
    bgLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:bgLayer atIndex:0];
    
    [[takePhoto layer] setBorderWidth:2.0f];
    [[takePhoto layer] setBorderColor:[UIColor whiteColor].CGColor];
    takePhoto.layer.cornerRadius = 10; // this value vary as per your desire
    takePhoto.clipsToBounds = YES;
    
    textBox.layer.cornerRadius = 5;
    textBox.clipsToBounds = YES;
    
    imageView.layer.cornerRadius = 10;
    imageView.clipsToBounds = YES;
    
    [[addFoodStep layer] setBorderWidth:2.0f];
    [[addFoodStep layer] setBorderColor:[UIColor whiteColor].CGColor];
    addFoodStep.layer.cornerRadius = 10; // this value vary as per your desire
    addFoodStep.clipsToBounds = YES;

    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)getCurrentLocation:(id)sender
{
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager requestWhenInUseAuthorization];
    //[locationManager requestAlwaysAuthorization];
    [locationManager startUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    //NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        longitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        latitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
    }
    
    //NSLog(@"%@, %@",longitude, latitude);
    
    //NSLog(@"Resolving the Address");
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            addressLabel.text = [NSString stringWithFormat:@"%@\n%@ %@\n%@, %@ %@",
                                 placemark.name,
                                 placemark.subThoroughfare, placemark.thoroughfare,
                                 placemark.locality,
                                 placemark.administrativeArea,
                                 placemark.postalCode];
            placeName = placemark.name;
            addressLine1 = [NSString stringWithFormat:@"%@ %@", placemark.subThoroughfare, placemark.thoroughfare];
            addressLine2 = [NSString stringWithFormat:@"%@, %@ %@", placemark.locality, placemark.administrativeArea, placemark.postalCode];
            
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    } ];
    
    //addressLabel.text = (NSString *)[NSDate date];
    //NSLog(@"%@", addressLabel.text);
    
}

// The number of columns of data
- (long)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (long)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _pickerData.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _pickerData[row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    selectedEntry = [_pickerData objectAtIndex:row];
}

- (IBAction)takePhoto:(id)sender {
    
    picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [self presentViewController:picker animated:YES completion:NULL];

}

- (IBAction)sharePost:(id)sender
{
    FIRStorage *storage = [FIRStorage storage];
    FIRStorageReference *storageRef = [storage referenceForURL:@"gs://foodsteps-cee33.appspot.com"];
    
    long currentTime = (long)(NSTimeInterval)([[NSDate date] timeIntervalSince1970]);
    
    NSString *time = [NSString stringWithFormat:@"%ld", currentTime];
    
    NSString *postTimeStamp = [@"post" stringByAppendingString:time];
    
    if(textBox.text.length >0 && addressLabel.text.length >0)
    {
    
    [[[[[_ref child:@"users"] child:fbID] child:postTimeStamp] child:@"email"] setValue:email];
        [[[[[_ref child:@"users"] child:fbID] child:postTimeStamp] child:@"name"] setValue:name];
    [[[[[_ref child:@"users"] child:fbID] child:postTimeStamp] child:@"description"] setValue:textBox.text];
    [[[[[_ref child:@"users"] child:fbID] child:postTimeStamp] child:@"placeName"] setValue:placeName];
    [[[[[_ref child:@"users"] child:fbID] child:postTimeStamp] child:@"addressLine1"]setValue:addressLine1];
    [[[[[_ref child:@"users"] child:fbID] child:postTimeStamp] child:@"addressLine2"]setValue:addressLine2];
    [[[[[_ref child:@"users"] child:fbID] child:postTimeStamp] child:@"rating"]setValue:selectedEntry];
        
        NSData *imageData = UIImagePNGRepresentation(imageView.image);
        uploadPath = [NSString stringWithFormat:@"%@/%@.png", fbID, postTimeStamp];
        
        if(imageData)
        {
            FIRStorageReference *postPicReference = [storageRef child:uploadPath ];
            
            FIRStorageUploadTask *uploadTask = [postPicReference putData:imageData metadata:nil completion:^(FIRStorageMetadata *metadata, NSError *error) {
                if (error != nil) {
                    NSLog(@"Error downloading!");
                }
                
                else {
                    // Metadata contains file metadata such as size, content-type, and download URL.
                    NSURL *downloadURL = metadata.downloadURL;
                    
                    
                    
                    
                    
                }
                
            }];
            
            
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Status"
                                                        message:@"Your foodstep has been posted"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        
        [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
        
    }
    
    else
    {
        NSLog(@"Description or location cannot be empty!");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Status"
                                                        message:@"Description or location cannot be empty"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        
        [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
    }
}

-(void)twitterExceptionHandling:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops!!" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"User pressed Cancel");
                                   }];
    
    UIAlertAction *settingsAction = [UIAlertAction
                                     actionWithTitle:NSLocalizedString(@"Settings", @"Settings action")
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action)
                                     {
                                         NSLog(@"Settings Pressed");
                                         
                                         //code for opening settings app in iOS 8
                                         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                         
                                     }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:settingsAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    image=[info objectForKey:@"UIImagePickerControllerOriginalImage"];
    [imageView setImage:image];
    //imageView.transform = CGAffineTransformMakeRotation(M_PI);
    
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    flag = 1;
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)dismissKeyboard {
    [textBox resignFirstResponder];
}

@end

