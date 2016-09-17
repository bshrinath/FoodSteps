//
//  MapPin.h
//  foodsteps1
//
//  Created by Shrinath on 8/2/16.
//  Copyright © 2016 cmu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapPin : NSObject <MKAnnotation>
@property(nonatomic,assign) CLLocationCoordinate2D coordinate;
@property(nonatomic,copy) NSString *title;
@property(nonatomic,copy) NSString *subtitle;
@end

#import "MapPin.h"

@implementation MapPin

@end
