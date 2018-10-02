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
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd/yy"];
        NSDate *date = [dateFormatter dateFromString:schedule.strDate];
        
        // today's date
        NSDate *currDate = [NSDate date];
        NSDateComponents *componentsToday = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:currDate];
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
        
        // checking if Majlis is today .
        
        BOOL isToday = [componentsToday year] == [components year] &&
                        [componentsToday month] == [components month] &&
                        [componentsToday day] == [components day];
        
        // we are ignoring Majalis happened in the past. We will show only those are schedulled today and in the future.
        
        NSComparisonResult result = [currDate compare:date];
        if( result == NSOrderedAscending || isToday){
            [array addObject:schedule];
        }
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
    schedule.strMasayab  = dictionary[@"Masayab"];
    
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
