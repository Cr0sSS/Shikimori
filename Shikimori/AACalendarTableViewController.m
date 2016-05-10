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

@property (strong, nonatomic) NSMutableArray *animes;
@property (strong, nonatomic) AAAnimeCalendar *animeCalendar;
@property (strong, nonatomic) UIImage *placeholder;
@property (strong, nonatomic) NSString *sectionName;
@property (strong, nonatomic) NSSet *uniqueDateNextEpisodeAt;
@property (strong, nonatomic) NSMutableArray *rowsInSection;
@property (strong, nonatomic) NSArray *titlesForHeaderInSection;

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

    self.tableView.tableFooterView = [UIView new];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.tableView.rowHeight = 240;
    } else {
        self.tableView.rowHeight = 120;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - API Methods

- (void) getAnimeCalendarFromServer {
    
    [SVProgressHUD show];
    
    [[AAServerManager shareManager] getAnimeOngoingCalendar:^(NSArray *animeCalendar) {
        self.animes = [NSMutableArray array];
        [self.animes addObjectsFromArray:animeCalendar];
        
        NSArray *nextEpisodeAtArray = [self.animes valueForKey:@"nextEpisodeAt"];
        NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:nextEpisodeAtArray];
        self.uniqueDateNextEpisodeAt = [orderedSet set];
        
        [self.tableView reloadData];
        [SVProgressHUD dismiss];
    } onFailure:^(NSError *error, NSInteger statusCode) {
        [SVProgressHUD dismiss];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка"
                                                        message:@"Не удалось получить данные. Попробовать еще раз?"
                                                       delegate:self
                                              cancelButtonTitle:@"Нет"
                                              otherButtonTitles:@"Да", nil];
        [alert show];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.uniqueDateNextEpisodeAt count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    self.rowsInSection = [NSMutableArray array];
    for (AAAnimeCalendar *anime in self.animes) {
        if ([anime.nextEpisodeAt isEqualToString:[self.titlesForHeaderInSection objectAtIndex:section]]) {
            [self.rowsInSection addObject:anime];
        }
    }
    return [self.rowsInSection count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const reuseIdentifier = @"Cell";
    AAAnimeCalendarViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[AAAnimeCalendarViewCell alloc] init];
    }
    
    self.rowsInSection = [NSMutableArray array];
    for (AAAnimeCalendar *anime in self.animes) {
        if ([anime.nextEpisodeAt isEqualToString:[self.titlesForHeaderInSection objectAtIndex:indexPath.section]]) {
            [self.rowsInSection addObject:anime];
        }
    }
    
    self.animeCalendar = [self.rowsInSection objectAtIndex:indexPath.row];
    
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
    self.titlesForHeaderInSection = [self.uniqueDateNextEpisodeAt allObjects];
    return [self.titlesForHeaderInSection objectAtIndex:section];
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if ([title isEqualToString:@"Да"]) {
        [self getAnimeCalendarFromServer];
    }
}


#pragma mark - Navigation Methods

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    
    if ([[segue identifier] isEqualToString:@"ShowAnimeProfile"]) {
        
        self.rowsInSection = [NSMutableArray array];
        for (AAAnimeCalendar *anime in self.animes) {
            if ([anime.nextEpisodeAt isEqualToString:[self.titlesForHeaderInSection objectAtIndex:indexPath.section]]) {
                [self.rowsInSection addObject:anime];
            }
        }
        
        AAAnimeProfile *anime = [self.rowsInSection objectAtIndex:indexPath.row];
        AAAnimeProfileViewController *destination1 = [segue destinationViewController];
        destination1.animeID = anime.animeID;
    }
}

- (void)showSearchController {
    UIViewController *searchVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
    [self.navigationController pushViewController:searchVC animated:YES];
}

#pragma mark - Another Methods

- (void) setCALayerForImage:(AAAnimeCalendarViewCell *)cell {
    CALayer *cellImageLayer = cell.calendarAnimeImageView.layer;
    [cellImageLayer setCornerRadius:4];
    [cellImageLayer setMasksToBounds:YES];
}

@end
