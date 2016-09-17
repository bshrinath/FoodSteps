//
//  Background.h
//  foodsteps1
//
//  Created by Shrinath on 7/30/16.
//  Copyright © 2016 cmu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface BackgroundLayer : NSObject

+(CAGradientLayer*) greyGradient;
+(CAGradientLayer*) blueGradient;

@end
