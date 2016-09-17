//
//  FirstViewController.h
//  foodsteps1
//
//  Created by Shrinath on 7/22/16.
//  Copyright © 2016 cmu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "Accounts/Accounts.h"
#import "Social/Social.h"
#import "CoreLocation/CoreLocation.h"
@import FirebaseAuth;
@import FirebaseDatabase;

@interface CameraViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, CLLocationManagerDelegate>
{
    
    IBOutlet UIImageView *imageView;
    UIImagePickerController *picker;
    UIImage *image;
    
    __weak IBOutlet UIPickerView *pickerView;
    CLLocationManager *locationManager;
    
    __weak IBOutlet UILabel *addressLabel;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    
    __weak IBOutlet UITextView *textBox;
    
    
    __weak IBOutlet UIButton *takePhoto;
    __weak IBOutlet UIButton *addFoodStep;
    

}

@property (strong, nonatomic) FIRDatabaseReference *ref;
//@property (strong, nonatomic) FirebaseTableViewDataSource *dataSource;

- (IBAction)sharePost:(id)sender;
- (IBAction)takePhoto:(id)sender;
- (IBAction)getCurrentLocation:(id)sender;
@end
