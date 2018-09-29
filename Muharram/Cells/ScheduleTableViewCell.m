//
//  ScheduleCellTableViewCell.m
//  Muharram
//
//  Created by Syed Naqvi on 9/28/18.
//  Copyright © 2018 Syed Naqvi. All rights reserved.
//

#import "ScheduleTableViewCell.h"
#import "Client.h"

@interface ScheduleTableViewCell()
@property (weak, nonatomic) IBOutlet UITextView *tvName;
@property (weak, nonatomic) IBOutlet UITextView *tvAddress;
@property (weak, nonatomic) IBOutlet UITextView *tvDate;
@property (weak, nonatomic) IBOutlet UITextView *tvTime;
@property (weak, nonatomic) IBOutlet UITextView *tvPhone;
@end


@implementation ScheduleTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void) setSchedule:(MuharramSchedule *)schedule{

    // Converted date from date string
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yy"];
    NSDate *date = [dateFormatter dateFromString:schedule.strDate];

    NSString* strDate = [NSDateFormatter localizedStringFromDate:date                       dateStyle:NSDateFormatterFullStyle
        timeStyle:NSDateFormatterNoStyle];
    
    [self.tvName setText:schedule.strName];
    [self.tvAddress setText:schedule.strAddress];
    [self.tvDate setText:strDate];
    [self.tvTime setText:schedule.strTime];
    [self.tvPhone setText:schedule.strPhone];
}

-(NSString*) getFirstWordFromString:(NSString*)text{
    NSRange range = [text rangeOfString:@" "];
    if (range.location != NSNotFound) {
        return [text substringToIndex:range.location];
    }
    return nil;
}

-(void) setImageForDay:(NSString*) day{
    if(day == nil)
        return;
    
    // Currently, our icons are having the same name as of days so no need to map.
    // otherise we may need to have a dictionary to have a mapping from "Day" to Image.
    //self.programImageView.image = [UIImage imageNamed:day];
}


@end
