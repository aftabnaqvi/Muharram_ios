//
//  MuharramSchedule.m
//  Muharram
//
//  Created by Syed Naqvi on 9/28/18.
//  Copyright © 2018 Syed Naqvi. All rights reserved.
//

#import "MuharramSchedule.h"

@implementation MuharramSchedule

+(NSArray*) fromJSONArray:(NSArray*) scheduleArray{
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for(NSDictionary* dic in scheduleArray){
        MuharramSchedule* schedule = [MuharramSchedule fromDictionary:dic];
        [array addObject:schedule];
    }
    
    return array;
}

+(MuharramSchedule*) fromDictionary:(NSDictionary*)dictionary{
    MuharramSchedule* schedule = [[MuharramSchedule alloc] init];
    schedule.strName     = dictionary[@"Name"];
    schedule.strDay      = dictionary[@"Day"];
    schedule.strDate      = dictionary[@"Date"];
    schedule.strTime     = dictionary[@"Time"];
    schedule.strAddress  = dictionary[@"Address"];
    schedule.strPhone    = dictionary[@"Phone"];    
    return schedule;
}

// debug function...
-(void) display{
    NSLog(@"Name: %@", self.strName);
    NSLog(@"Day: %@", self.strDay);
    NSLog(@"Date: %@", self.strDate);
    NSLog(@"Time: %@", self.strTime);
    NSLog(@"Address: %@", self.strAddress);
    NSLog(@"Phone: %@", self.strPhone);
}

@end
