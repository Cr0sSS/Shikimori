//
//  AACalendarTableViewController.m
//  Shikimori
//
//  Created by Admin on 29.04.16.
//  Copyright © 2016 Arsen Avanesyan. All rights reserved.
//

#import "AACalendarTableViewController.h"
#import "AAServerManager.h"
#import "SVProgressHUD.h"
#import "SWRevealViewController.h"
#import "AAAnimeCalendarViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "AAAnimeProfileViewController.h"

@interface AACalendarTableViewController ()

@property (strong, nonatomic) NSMutableArray *animeArray;
@property (strong, nonatomic) AAAnimeCalendar *animeCalendar;
@property (strong, nonatomic) UIImage *placeholder;
@property (strong, nonatomic) NSString *sectionName;
@property (strong, nonatomic) NSSet *uniqueDateNextEpisodeAtSet;
@property (strong, nonatomic) NSMutableArray *rowsInSectionArray;
@property (strong, nonatomic) NSArray *titleForHeaderInSectionArray;

@end

@implementation AACalendarTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self getAnimeCalendarFromServer];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:25/255.0 green:181/255.0 blue:254/255.0 alpha:1];
    
    SWRevealViewController *revealController = [self revealViewController];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_menu"] style:UIBarButtonItemStylePlain target:revealController action:@selector(revealToggle:)];
    [self.navigationController.navigationBar.topItem setLeftBarButtonItem:revealButtonItem];
    [revealButtonItem setTintColor:[UIColor whiteColor]];
    
    UIBarButtonItem *searchButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(showSearchController)];
    [self.navigationController.navigationBar.topItem setRightBarButtonItem:searchButtonItem];
    [searchButtonItem setTintColor:[UIColor whiteColor]];
    
    self.placeholder = [UIImage imageNamed:@"imageholder"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showSearchController {
    UIViewController *searchVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
    [self.navigationController pushViewController:searchVC animated:YES];
}

- (void) setCALayerForImage:(AAAnimeCalendarViewCell *)cell {
    CALayer *cellImageLayer = cell.calendarAnimeImageView.layer;
    [cellImageLayer setCornerRadius:4];
    [cellImageLayer setMasksToBounds:YES];
}

#pragma mark - API Methods

- (void) getAnimeCalendarFromServer {
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    [blurEffectView setFrame:self.view.frame];
    [self.view addSubview:blurEffectView];
    
    [SVProgressHUD show];
    
    [[AAServerManager shareManager] getAnimeOngoingCalendar:^(NSArray *animeCalendar) {
        self.animeArray = [NSMutableArray array];
        [self.animeArray addObjectsFromArray:animeCalendar];
        
        NSArray *nextEpisodeAtArray = [self.animeArray valueForKey:@"nextEpisodeAt"];
        NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:nextEpisodeAtArray];
        self.uniqueDateNextEpisodeAtSet = [orderedSet set];
        
        [self.tableView reloadData];
        [blurEffectView removeFromSuperview];
        [SVProgressHUD dismiss];
    } onFailure:^(NSError *error, NSInteger statusCode) {
        [blurEffectView removeFromSuperview];
        [SVProgressHUD dismiss];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.uniqueDateNextEpisodeAtSet count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    self.rowsInSectionArray = [NSMutableArray array];
    for (AAAnimeCalendar *anime in self.animeArray) {
        if ([anime.nextEpisodeAt isEqualToString:[self.titleForHeaderInSectionArray objectAtIndex:section]]) {
            [self.rowsInSectionArray addObject:anime];
        }
    }
    return [self.rowsInSectionArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const reuseIdentifier = @"Cell";
    AAAnimeCalendarViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[AAAnimeCalendarViewCell alloc] init];
    }
    
    self.rowsInSectionArray = [NSMutableArray array];
    for (AAAnimeCalendar *anime in self.animeArray) {
        if ([anime.nextEpisodeAt isEqualToString:[self.titleForHeaderInSectionArray objectAtIndex:indexPath.section]]) {
            [self.rowsInSectionArray addObject:anime];
        }
    }
    
    self.animeCalendar = [self.rowsInSectionArray objectAtIndex:indexPath.row];
    
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://shikimori.org%@", self.animeCalendar.imageURL]]];
    
    __weak AAAnimeCalendarViewCell* weakCell = cell;
    
    [cell.calendarAnimeImageView
     setImageWithURLRequest:request
     placeholderImage:self.placeholder
     success:^(NSURLRequest * request, NSHTTPURLResponse *response, UIImage *image) {
         weakCell.calendarAnimeImageView.image = image;
         [weakCell layoutSubviews];
     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
         NSLog(@"%@", error);
     }];
    
    [self setCALayerForImage:cell];
    
    cell.calendarAnimeNameLabel.text = [NSString stringWithFormat:@"%@", self.animeCalendar.russian];
    cell.calendarAnimeNextEpisode.text = [NSString stringWithFormat:@"%@ эпизод", self.animeCalendar.nextEpisode];
    cell.calendarAnimeType.text = [NSString stringWithFormat:@"%@", self.animeCalendar.kind];
    
    cell.calendarAnimeNameLabel.textColor = [UIColor colorWithRed:25/255.0 green:181/255.0 blue:254/255.0 alpha:1];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    self.titleForHeaderInSectionArray = [self.uniqueDateNextEpisodeAtSet allObjects];
    return [self.titleForHeaderInSectionArray objectAtIndex:section];
}

#pragma mark - Navigation Methods

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    
    if ([[segue identifier] isEqualToString:@"ShowAnimeProfile"]) {
        
        self.rowsInSectionArray = [NSMutableArray array];
        for (AAAnimeCalendar *anime in self.animeArray) {
            if ([anime.nextEpisodeAt isEqualToString:[self.titleForHeaderInSectionArray objectAtIndex:indexPath.section]]) {
                [self.rowsInSectionArray addObject:anime];
            }
        }
        
        AAAnimeProfile *anime = [self.rowsInSectionArray objectAtIndex:indexPath.row];
        AAAnimeProfileViewController *destination1 = [segue destinationViewController];
        destination1.animeID = anime.animeID;
    }
}

@end
