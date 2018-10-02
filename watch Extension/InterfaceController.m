//
//  InterfaceController.m
//  watch Extension
//
//  Created by Aftab Naqvi on 9/30/18.
//  Copyright © 2018 Syed Naqvi. All rights reserved.
//

#import "InterfaceController.h"


@interface InterfaceController ()

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    [self.myLabel setText:@"0"];
    
    
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (IBAction)upButton {
    NSLog(@" up button clicked");
    [self.myLabel setText:@"000000000"];
    
    [self.myLabel setTextColor:[UIColor redColor]];
    [self.myLabel setHidden:YES];
    
    //[self.upButtonOutlet setBackgroundColor:[UIColor redColor]];
    
}

- (IBAction)dwonButton {
    NSLog(@" Bottom button clicked");
    self.myLabel.text = @"downnnnnn";
}

@end



