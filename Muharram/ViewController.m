//
//  ViewController.m
//  Muharram
//
//  Created by Syed Naqvi on 9/25/18.
//  Copyright © 2018 Syed Naqvi. All rights reserved.
//

#import "Client.h"
#import "ViewController.h"
#import "MuharramSchedule.h"
#import "ScheduleTableViewCell.h"
#import "UIImage+ImageEffects.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
{
    CGFloat _headerHeight;
    CGFloat _subHeaderHeight;
    CGFloat _headerSwitchOffset;
    CGFloat _profileImageSize;
    CGFloat _profileCompressedImageSize;
    BOOL _barIsCollapsed;
    BOOL _barAnimationComplete;
}

@property (weak) UITableView *tableView;
@property (weak) UIImageView *imageHeaderView;
@property (weak) UIVisualEffectView *visualEffectView;
@property (strong,nonatomic) UIView *customTitleView;
@property (strong) UIImage *originalBackgroundImage;

@property (strong) NSMutableDictionary* blurredImageCache;
@property bool isRefreshInProgress; // keeps track that if refresh is in Progress. Another refresh should not kick in at the sametime.

@property (strong, nonatomic) NSArray *muharramSchedule;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureNavBar];
    [self setupUI];
    [self getMuharramSchedule];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    if ([self isViewLoaded] && self.view.window){
        /*strong ref to this*/
        _customTitleView = nil;
    }
}

- (void)dealloc{
    _originalBackgroundImage = nil;
    [_blurredImageCache removeAllObjects];
    _blurredImageCache = nil;
}

// setupUI

- (void)setupUI {
    
    _headerHeight = 180.0;
    _subHeaderHeight = 75.0;
    _profileImageSize = 70;
    _profileCompressedImageSize = 44;
    _barIsCollapsed = false;
    _barAnimationComplete = false;
    
    UIApplication* sharedApplication = [UIApplication sharedApplication];
    CGFloat kStatusBarHeight = sharedApplication.statusBarFrame.size.height;
    CGFloat kNavBarHeight =  self.navigationController.navigationBar.frame.size.height;
    
    _headerSwitchOffset = _headerHeight - /* To compensate  the adjust scroll insets */(kStatusBarHeight + kNavBarHeight)  - kStatusBarHeight - kNavBarHeight;
    
    NSMutableDictionary* views = [NSMutableDictionary new];
    views[@"super"] = self.view;
    
    UITableView* tableView = [[UITableView alloc] init];
    tableView.translatesAutoresizingMaskIntoConstraints = NO; //autolayout
    tableView.delegate = self;
    tableView.dataSource = self;
    self.tableView = tableView;
    [self.view addSubview:tableView];
    views[@"tableView"] = tableView;
    
    // register cell for TableView
    [self.tableView registerNib:[UINib nibWithNibName:@"ScheduleTableViewCell" bundle:nil] forCellReuseIdentifier:@"ScheduleTableViewCell"];
    
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    
    self.tableView.estimatedRowHeight = 100;//the estimatedRowHeight but if is more this autoincremented with autolayout
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView setNeedsLayout];
    [self.tableView layoutIfNeeded];
    self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0) ;
    
    UIImage* imageBackground = [UIImage imageNamed:@"shrine_Imam.jpg"];
    _originalBackgroundImage = imageBackground;
    
    UIImageView* headerImageView = [[UIImageView alloc] initWithImage:imageBackground];
    headerImageView.translatesAutoresizingMaskIntoConstraints = NO; //autolayout
    headerImageView.contentMode = UIViewContentModeScaleAspectFill;
    headerImageView.clipsToBounds = true;
    self.imageHeaderView = headerImageView;
    views[@"headerImageView"] = headerImageView;
    
    /* Not using autolayout for this one, because i don't really have control on how the table view is setting up the items.*/
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,
                                                                       _headerHeight - /* To compensate  the adjust scroll insets */(kStatusBarHeight + kNavBarHeight) + _subHeaderHeight)];
    
    [tableHeaderView addSubview:headerImageView];
    
    UIView* subHeaderPart = [self createSubHeaderView];// [[UIView alloc] init];
    subHeaderPart.translatesAutoresizingMaskIntoConstraints = NO; //autolayout
    subHeaderPart.backgroundColor  = [UIColor brownColor]; // header color
    [tableHeaderView insertSubview:subHeaderPart belowSubview:headerImageView];
    views[@"subHeaderPart"] = subHeaderPart;
    
    tableView.tableHeaderView = tableHeaderView;
    
    UIImageView* ivProfile = [self createAvatarImage];
    ivProfile.translatesAutoresizingMaskIntoConstraints = NO; //autolayout
    views[@"profileImageView"] = ivProfile;
    [tableHeaderView addSubview:ivProfile];
    
    /*
     * At this point tableHeader views are ordered like this:
     * 0 : subHeaderPart
     * 1 : headerImageView
     * 2 : profileImageView
     */
    
    /* This is important, or section header will 'overlaps' the navbar */
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    
    //Now Let's do the layout
    NSArray* constraints;
    NSLayoutConstraint* constraint;
    NSString* format;
    NSDictionary* metrics = @{
                              @"headerHeight" : [NSNumber numberWithFloat:_headerHeight- /* To compensate  the adjust scroll insets */(kStatusBarHeight + kNavBarHeight) ],
                              @"minHeaderHeight" : [NSNumber numberWithFloat:(kStatusBarHeight + kNavBarHeight)],
                              @"profileSize" :[NSNumber numberWithFloat:_profileImageSize],
                              @"profileCompressedSize" :[NSNumber numberWithFloat:_profileCompressedImageSize],
                              @"subHeaderHeight" :[NSNumber numberWithFloat:_subHeaderHeight],
                              };
    
    // Table view should take all available space
    
    format = @"|-0-[tableView]-0-|";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
    [self.view addConstraints:constraints];
    
    format = @"V:|-0-[tableView]-0-|";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
    [self.view addConstraints:constraints];
    
    // Header image view should take all available width
    
    format = @"|-0-[headerImageView]-0-|";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
    [tableHeaderView addConstraints:constraints];
    
    format = @"|-0-[subHeaderPart]-0-|";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
    [tableHeaderView addConstraints:constraints];
    
    // Header image view should not be smaller than nav bar and stay below navbar
    
    format = @"V:[headerImageView(>=minHeaderHeight)]-(subHeaderHeight@750)-|";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
    [self.view addConstraints:constraints];
    
    format = @"V:|-(headerHeight)-[subHeaderPart(subHeaderHeight)]";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
    [self.view addConstraints:constraints];
    
    // Header image view should stick to top of the 'screen'
    
    NSLayoutConstraint* magicConstraint = [NSLayoutConstraint constraintWithItem:headerImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0];
    [self.view addConstraint: magicConstraint];
    
    // profile image should stick to left with default margin spacing
    
    format = @"|-[profileImageView]";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
    [self.view addConstraints:constraints];
    
    
    // profile image is square
    constraint = [NSLayoutConstraint constraintWithItem:ivProfile attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:ivProfile attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0];
    [self.view addConstraint: constraint];
    
    // profile image size can be between avatarSize and avatarCompressedSize
    
    format = @"V:[profileImageView(<=profileSize@760,>=profileCompressedSize@800)]";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
    [self.view addConstraints:constraints];
    
    constraint = [NSLayoutConstraint constraintWithItem:ivProfile attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:(kStatusBarHeight + kNavBarHeight)];
    constraint.priority = 790;
    [self.view addConstraint: constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:ivProfile attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:subHeaderPart attribute:NSLayoutAttributeBottom multiplier:1.0f constant:-50.0];
    constraint.priority = 801;
    [self.view addConstraint: constraint];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self fillBlurredImageCache];
    });
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.muharramSchedule.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ScheduleTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"ScheduleTableViewCell" forIndexPath:indexPath];
    
    // This is how you change the background color. We might have better sol.
    ///UIView *bgColorView = [[UIView alloc] init];
    ///bgColorView.backgroundColor = [UIColor grayColor];
    ///[cell setSelectedBackgroundView:bgColorView];
    
    MuharramSchedule *schedule = self.muharramSchedule[indexPath.row];
    [cell setSchedule:schedule];
    
    // checking and addind details for Mubasher bhai's Majlis details...
    if([schedule.strMasayab containsString:@"Shabber Ali Khan"]){
        UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        // set the button's target to this table view controller so we can interpret touch events and map that to a NSIndexSet
        [button addTarget:self action:@selector(accessoryTapped:event:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = button;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell =
    [self.tableView dequeueReusableCellWithIdentifier:@"ScheduleTableViewCell"];
    
    return cell.bounds.size.height;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    // Show details for Mubasher bhai's house Majlis details...
}

- (void)accessoryTapped:(id)sender event:(id)event{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: currentTouchPosition];
    if (indexPath != nil){
        [self tableView: self.tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
    }
}

#pragma mark - NavBar configuration

- (void) configureNavBar {
    
    self.view.backgroundColor = [UIColor blueColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshClicked)];
    
    [self switchToExpandedHeader];
}

- (void)switchToExpandedHeader
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.titleView = nil;
    
    _barAnimationComplete = false;
    self.imageHeaderView.image = self.originalBackgroundImage;
    
    //Inverse Z-Order of avatar Image view
    [self.tableView.tableHeaderView exchangeSubviewAtIndex:1 withSubviewAtIndex:2];
}

- (void)switchToMinifiedHeader
{
    _barAnimationComplete = false;
    
    self.navigationItem.titleView = self.customTitleView;
    self.navigationController.navigationBar.clipsToBounds = YES;
    
    //Setting the view transform or changing frame origin has no effect, only this call does
    
    [self.navigationController.navigationBar setTitleVerticalPositionAdjustment:60 forBarMetrics:UIBarMetricsDefault];
    
    //Inverse Z-Order of avatar Image view
    
    [self.tableView.tableHeaderView exchangeSubviewAtIndex:1 withSubviewAtIndex:2];
}


#pragma mark - UIScrollView delegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat yPos = scrollView.contentOffset.y;
    if (yPos > _headerSwitchOffset && !_barIsCollapsed) {
        [self switchToMinifiedHeader];
        _barIsCollapsed = true;
    } else if (yPos < _headerSwitchOffset && _barIsCollapsed) {
        [self switchToExpandedHeader];
        _barIsCollapsed = false;
    }
    
    if(yPos > _headerSwitchOffset + 20 && yPos <= _headerSwitchOffset + 20 + 40){
        CGFloat delta = (40 + 20 - (yPos-_headerSwitchOffset));
        [self.navigationController.navigationBar setTitleVerticalPositionAdjustment:delta forBarMetrics:UIBarMetricsDefault];
        
        self.imageHeaderView.image = [self blurWithImageAt:((60-delta)/60.0)];
    }
    
    if(!_barAnimationComplete && yPos > _headerSwitchOffset + 20 + 40) {
        [self.navigationController.navigationBar setTitleVerticalPositionAdjustment:0 forBarMetrics:UIBarMetricsDefault];
        self.imageHeaderView.image = [self blurWithImageAt:1.0];
        _barAnimationComplete = true;
    }
}

#pragma mark - privates

- (UIImageView*) createAvatarImage {
    UIImageView* avatarView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Labbaik-ya-Hussain.jpg"]];
    avatarView.contentMode = UIViewContentModeScaleToFill;
    avatarView.layer.cornerRadius = 8.0;
    avatarView.layer.borderWidth = 3.0f;
    avatarView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    avatarView.clipsToBounds = YES;
    return avatarView;
}

- (UIView*) customTitleView {
    if(!_customTitleView){
        UILabel* labelName = [UILabel new];
        labelName.translatesAutoresizingMaskIntoConstraints = NO;
        labelName.text = @"Anjuman-e-Ansarul Mehdi (A.S)";
        labelName.numberOfLines =1;
        
        [labelName setTextColor:[UIColor whiteColor]];
        [labelName setFont:[UIFont boldSystemFontOfSize:15.0f]];
        
        // get Current date...
        
        NSString* englishDate = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                               dateStyle:NSDateFormatterFullStyle
                                                               timeStyle:NSDateFormatterNoStyle];
        
        UILabel* currDate = [UILabel new];
        currDate.translatesAutoresizingMaskIntoConstraints = NO;
        currDate.text = englishDate;
        currDate.numberOfLines =1;
        
        [currDate setTextColor:[UIColor whiteColor]];
        [currDate setFont:[UIFont boldSystemFontOfSize:10.0f]];
        
        UIView* wrapper = [UIView new];
        [wrapper addSubview:labelName];
        [wrapper addSubview:currDate];
        
        [wrapper addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[labelName]-0-|" options:0 metrics:nil views:@{@"labelName": labelName,@"currDate":currDate}]];
        [wrapper addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[labelName]-2-[currDate]-0-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:@{@"labelName": labelName,@"currDate":currDate}]];
        
        //mmm.. it seems that i have to set it like this, if not the view size is set to 0 by the navabar layout..
        wrapper.frame = CGRectMake(0, 0, MAX(labelName.intrinsicContentSize.width,currDate.intrinsicContentSize.width), labelName.intrinsicContentSize.height + currDate.intrinsicContentSize.height + 2);
        
        wrapper.clipsToBounds = true;
        
        _customTitleView  = wrapper;
    }
    return _customTitleView;
}

#pragma refresh button handling

-(void)refreshClicked{
    [self getMuharramSchedule];
}

#pragma mark get Muharram Schedule

-(void) getMuharramSchedule{
    // get the program from the local database. If records are there then no need to make a network call.
    
    if(self.isRefreshInProgress)
        return;
    
    self.isRefreshInProgress = true;
    [[Client sharedInstance] showSpinner:YES];
    
    // go ahead and fetch the muharramSchedule via network call.
    [[Client sharedInstance] getMuharramSchedule:^(NSArray *muharramSchedule, NSError *error) {
        [[Client sharedInstance] showSpinner:NO];
        self.isRefreshInProgress = false;
        if (error) {
            NSLog(@"Error getting muharramSchedule: %@", error);
        } else {
            self.muharramSchedule = [MuharramSchedule fromJSONArray: muharramSchedule];
            [self.tableView reloadData];
        }
    }];
}

- (UIView*) createSubHeaderView {
    UIView* view = [UIView new];
    
    NSMutableDictionary* views = [NSMutableDictionary new];
    views[@"super"] = self.view;
    
    UILabel* labelName = [UILabel new];
    labelName.translatesAutoresizingMaskIntoConstraints = NO;
    labelName.text = @"Anjuman-e-Ansarul Mehdi (A.S)";
    labelName.numberOfLines = 1;
    [labelName setFont:[UIFont boldSystemFontOfSize:18.0f]];
    views[@"nameLabel"] = labelName;
    [view addSubview:labelName];
    
    NSArray* constraints;
    NSString* format;
    
    format = @"|-[nameLabel]";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views];
    [view addConstraints:constraints];
    
    format = @"V:|-15-[nameLabel]";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views];
    [view addConstraints:constraints];
    
    format = @"H:|-100-[nameLabel]";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views];
    [view addConstraints:constraints];
    
    // get Current date...
    
    NSString* englishDate = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                           dateStyle:NSDateFormatterFullStyle
                                                           timeStyle:NSDateFormatterNoStyle];
    
    UILabel* labelDate = [UILabel new];
    labelDate.translatesAutoresizingMaskIntoConstraints = NO;
    labelDate.text = englishDate;
    labelDate.numberOfLines = 1;
    [labelDate setFont:[UIFont boldSystemFontOfSize:15.0f]];
    views[@"dateLabel"] = labelDate;
    [view addSubview:labelDate];
    
    format = @"|-[dateLabel]";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views];
    [view addConstraints:constraints];
    
    format = @"V:|-35-[dateLabel]";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views];
    [view addConstraints:constraints];
    
    format = @"H:|-100-[dateLabel]";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views];
    [view addConstraints:constraints];
    
    return view;
}

- (UIImage *)blurWithImageAt:(CGFloat)percent
{
    NSNumber* keyNumber = @0;
    if(percent <= 0.1){
        keyNumber = @1;
    } else if(percent <= 0.2) {
        keyNumber = @2;
    } else if(percent <= 0.3) {
        keyNumber = @3;
    } else if(percent <= 0.4) {
        keyNumber = @4;
    } else if(percent <= 0.5) {
        keyNumber = @5;
    } else if(percent <= 0.6) {
        keyNumber = @6;
    } else if(percent <= 0.7) {
        keyNumber = @7;
    } else if(percent <= 0.8) {
        keyNumber = @8;
    } else if(percent <= 0.9) {
        keyNumber = @9;
    } else if(percent <= 1) {
        keyNumber = @10;
    }
    UIImage* image = [_blurredImageCache objectForKey:keyNumber];
    if(image == nil){
        //TODO if cache not yet built, just compute and put in cache
        return _originalBackgroundImage;
    }
    return image;
}

- (UIImage *)blurWithImageEffects:(UIImage *)image andRadius: (CGFloat) radius
{
    return [image applyBlurWithRadius:radius tintColor:[UIColor colorWithWhite:1 alpha:0.2] saturationDeltaFactor:1.5 maskImage:nil];
}

- (void) fillBlurredImageCache {
    CGFloat maxBlur = 30;
    self.blurredImageCache = [NSMutableDictionary new];
    for (int i = 0; i <= 10; i++)
    {
        self.blurredImageCache[[NSNumber numberWithInt:i]] = [self blurWithImageEffects:_originalBackgroundImage andRadius:(maxBlur * i/10)];
    }
}

@end
