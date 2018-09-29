//
//  SabaClient.m
//  SabaApp
//
//  Created by Syed Naqvi on 4/25/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "Client.h"
#import "appDelegate.h"

// Third party libraries.
#import "UIImageView+AFNetworking.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"

static NSString *BASE_URL = @"https://script.google.com/macros/s/AKfycbxOLElujQcy1-ZUer1KgEvK16gkTLUqYftApjNCM_IRTL3HSuDk/exec?id=1CZ-5EaMUymPiQ4qz81HAGVkwA0ATU5NhSngmuLyMnuk&sheet=Sheet1";

@implementation Client

+(Client *) sharedInstance{
	static Client *instance = nil;
	
	// grand centeral dispatch which makes sure it will execute once.
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		if(instance == nil){
			instance = [[Client alloc] init];
		}
	});
	
	return instance;
}

-(void) getMuharramSchedule:(void (^)(NSArray *muharramSchedule, NSError *error))completion {
	// check the database, if lastUpdate was recent?
	
	// sheet # 2 is Upcoming programs
	NSURL *url = [NSURL URLWithString:BASE_URL];
	[self sendNetworkRequest:url completion:completion];
}

//-(void) sendNetworkRequest1:(NSURL*) url completion:(void (^)(NSArray *jsonResponse, NSError *error))completion{
//
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    [manager GET:@"http://example.com/resources.json" parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);
//    } failure:^(NSURLSessionTask *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
//    }];
//}

-(void) sendNetworkRequest:(NSURL*) url completion:(void (^)(NSArray *muharramSchedule, NSError *error))completion {
	
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:BASE_URL parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSDictionary *response = responseObject;
        
        completion([response valueForKey:@"Sheet1"] , nil);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

/// helper fuction - being used at many places. may find a good home for his function in future.
-(NSAttributedString*) getAttributedString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size withOpacity:(double)opacity{
	string = [string stringByAppendingString:[NSString stringWithFormat:@"<style>body{font-family: '%@'; font-size:%fpx;color: rgba(255, 255, 255, %.2f);}</style>", name, size, opacity]];
	
	//NSLog(@"string: %@", string);
	return [[NSAttributedString alloc]
			initWithData:[string dataUsingEncoding:NSUnicodeStringEncoding]
			options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
			documentAttributes:nil error:nil];
	
}
// Progress spinner helper function
-(void) showSpinner:(bool)show{
	if(show == YES){
		[SVProgressHUD setRingThickness:2.0];
		[SVProgressHUD setForegroundColor:[UIColor blackColor]];
		[SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
		[SVProgressHUD setBackgroundColor:[UIColor clearColor]];
		//[SVProgressHUD setForegroundColor:[UIColor whiteColor]];
	}
	else
		[SVProgressHUD dismiss];
}

// helper function for setting up the NavigationBar
-(void) setupNavigationBarFor:(UIViewController*) viewController{	
	// Settings bars text color to white.
	[viewController.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
	
	// following two lines makes the navigationBar transparent.
	[viewController.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
	viewController.navigationController.navigationBar.shadowImage = [UIImage new];
}

#pragma mark NSUserDefaults helper functions.
// NSUserDefaults helper functions
-(void) storePreferencesKey:(NSString*) key withValue:(NSString*) value {
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:value forKey:key];
	[defaults synchronize];
}

-(NSString*) getCachedPreferencesWithKey:(NSString*) key{
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	return [defaults stringForKey:key];
}

-(NSString*) getCachedHijriDate{
	NSString* englishDate = [NSDateFormatter localizedStringFromDate:[NSDate date]
														   dateStyle:NSDateFormatterFullStyle
														   timeStyle:NSDateFormatterNoStyle];
	
	if( (englishDate != nil) && [englishDate isEqualToString:[self getCachedEnglishDate]]){
		return [self getCachedPreferencesWithKey:@"hijriDate"];
	}
	
	return @"";
}

-(void) storeHijriDate:(NSString*) hijriDate{
	[self storeEnglishDate];
	[self storePreferencesKey:@"hijriDate"  withValue:hijriDate];
}

-(NSString*) getCachedEnglishDate{
	return [self getCachedPreferencesWithKey:@"englishDate"];
}

-(void) storeEnglishDate{
	NSString* englishDate = [NSDateFormatter localizedStringFromDate:[NSDate date]
														   dateStyle:NSDateFormatterFullStyle
														   timeStyle:NSDateFormatterNoStyle];
	
	[self storePreferencesKey:@"englishDate" withValue:englishDate];
}

@end
