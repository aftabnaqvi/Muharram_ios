//
//  ViewController.h
//  Muharram
//
//  Created by Syed Naqvi on 9/25/18.
//  Copyright © 2018 Syed Naqvi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITableViewDataSource,
UITableViewDelegate> {
}

@property (weak, nonatomic) IBOutlet UIScrollView *containerScrolView;
@property (weak, nonatomic) IBOutlet UIView *rootContainerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *headerView;



@end

