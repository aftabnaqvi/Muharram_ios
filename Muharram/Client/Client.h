//
//  SabaClient.h
//  SabaApp
//
//  Created by Syed Naqvi on 4/25/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface Client : NSObject

+ (Client *)sharedInstance;

-(void) getMuharramSchedule:(void (^)(NSArray *muharramSchedule, NSError *error))completion;

// helper functions, should move them to Utils, may be?
-(NSAttributedString*) getAttributedString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size withOpacity:(double)opacity;
-(void) showSpinner:(bool)show;
-(void) setupNavigationBarFor:(UIViewController*) viewController;

// NSUserDefaults helper functions
-(NSString*) getCachedHijriDate;
-(void) storeHijriDate:(NSString*) hijriDate;

@end
