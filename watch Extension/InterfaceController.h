//
//  InterfaceController.h
//  watch Extension
//
//  Created by Aftab Naqvi on 9/30/18.
//  Copyright © 2018 Syed Naqvi. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface InterfaceController : WKInterfaceController
//@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceGroup *tableView;
@property (strong, nonatomic) IBOutlet WKInterfaceLabel *myLabel;

- (IBAction)upButton;
- (IBAction)dwonButton;

@end
