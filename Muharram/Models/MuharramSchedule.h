//
//  MuharramSchedule.h
//  Muharram
//
//  Created by Syed Naqvi on 9/28/18.
//  Copyright © 2018 Syed Naqvi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MuharramSchedule : NSObject
@property (nonatomic, strong) NSString *strName;
@property (nonatomic, strong) NSString *strTime;
@property (nonatomic, strong) NSString *strAddress;
@property (nonatomic, strong) NSString *strDay;
@property (nonatomic, strong) NSString *strDate;
@property (nonatomic, strong) NSString *strPhone;
@property (nonatomic, strong) NSString *strMasayab;

//-(id)initWithDictionary:(NSDictionary * )dictionary;

// returns DailyProgram from dictionary (JSON)
+(MuharramSchedule*) fromDictionary:(NSDictionary*)dictionary;

+(NSArray*) fromJSONArray:(NSArray*) scheduleArray;

-(void) display;

@end
