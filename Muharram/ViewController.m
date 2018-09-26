//
//  ViewController.m
//  Muharram
//
//  Created by Syed Naqvi on 9/25/18.
//  Copyright © 2018 Syed Naqvi. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

NSMutableArray *myData;
float hearViewInitialHeight = 0.0;
NSLayoutConstraint *_headerViewTopAnchor;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _containerScrolView.delegate = self;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    // table view data is being set here
    myData = [[NSMutableArray alloc]initWithObjects:
              @"Data 1 in array",@"Data 2 in array",@"Data 3 in array",
              @"Data 4 in array",@"Data 5 in array",@"Data 5 in array",
              @"Data 6 in array",@"Data 7 in array",@"Data 8 in array",
              @"Data 9 in array", nil];
    // Do any additional setup after loading the view, typically from a nib.
    
    //_tableView.contentInset = UIEdgeInsetsMake(_headerView.frame.size.height, 0, 0, 0);
    
    //hearViewInitialHeight = _headerView.frame.size.height;
    
    //_headerViewTopAnchor = [[NSLayoutConstraint alloc] init];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(_headerViewTopAnchor == nil)
        return;
    
    int y = _containerScrolView.contentOffset.y - _tableView.contentOffset.y;
    _headerViewTopAnchor.constant = y - hearViewInitialHeight;
    
    if(_headerViewTopAnchor.constant > 0 || _headerViewTopAnchor.constant == -hearViewInitialHeight) {
        _headerViewTopAnchor.constant = 0;
    }
}

#pragma mark - Table View Data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:
(NSInteger)section {
    return [myData count]/2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:
(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:
                UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSString *stringForCell;
    
    if (indexPath.section == 0) {
        stringForCell= [myData objectAtIndex:indexPath.row];
    } else if (indexPath.section == 1) {
        stringForCell= [myData objectAtIndex:indexPath.row+ [myData count]/2];
    }
    [cell.textLabel setText:stringForCell];
    return cell;
}

// Default is 1 if not implemented
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:
(NSInteger)section {
    NSString *headerTitle;
    
    if (section==0) {
        headerTitle = @"Section 1 Header";
    } else {
        headerTitle = @"Section 2 Header";
    }
    return headerTitle;
}
*/
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
        return 100;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
        UIImage *myImage = [UIImage imageNamed:@"Icon-App-76x76@2x.png"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:myImage];
        imageView.frame = CGRectMake(10, 10, 60, 60);
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 70)];
        [view addSubview:imageView];
        
        return view;

}


/*
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:
(NSInteger)section {
    NSString *footerTitle;
    
    if (section==0) {
        footerTitle = @"Section 1 Footer";
    } else {
        footerTitle = @"Section 2 Footer";
    }
    return footerTitle;
}
*/
#pragma mark - TableView delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:
(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"Section:%d Row:%d selected and its data is %@",
          indexPath.section,indexPath.row,cell.textLabel.text);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
