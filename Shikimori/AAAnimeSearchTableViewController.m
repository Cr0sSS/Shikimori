//
//  AASearchAnimeTableViewController.m
//  Shikimori
//
//  Created by Admin on 17.04.16.
//  Copyright © 2016 Arsen Avanesyan. All rights reserved.
//

#import "AAAnimeSearchTableViewController.h"
#import "Anime+CoreDataProperties.h"
#import "AAAnimeSearchTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "AAAnimeProfileViewController.h"
#import "SVProgressHUD.h"

@interface AAAnimeSearchTableViewController ()

@property (strong, nonatomic) UIImage *placeholder;

@end

@implementation AAAnimeSearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [SVProgressHUD show];
    
    [self filter:@""];
    
    self.tableView.tableFooterView = [UIView new];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.tableView.rowHeight = 240;
    } else {
        self.tableView.rowHeight = 120;
    }
    
    self.placeholder = [UIImage imageNamed:@"imageholder"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    [SVProgressHUD dismiss];
}

- (NSManagedObjectContext*) managedObjectContext {
    
    if (!_managedObjectContext) {
        _managedObjectContext = [[AACoreDataManager sharedManager] managedObjectContext];
    }
    return _managedObjectContext;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (AAAnimeSearchTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    AAAnimeSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[AAAnimeSearchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)configureCell:(AAAnimeSearchTableViewCell*)cell atIndexPath:(NSIndexPath *)indexPath {
    Anime *anime = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.searchAnimeNameLabel.textColor = [UIColor colorWithRed:25/255.0 green:181/255.0 blue:254/255.0 alpha:1];
    
    if ([anime.russianName isEqual:[NSNull null]] || anime.russianName == nil) {
        cell.searchAnimeNameLabel.text = [NSString stringWithFormat:@"%@", anime.englishName];
    } else {
        cell.searchAnimeNameLabel.text = [NSString stringWithFormat:@"%@ / %@", anime.russianName, anime.englishName];
    }
    
    
    if ([anime.episodes isEqual:[NSNull null]] || [anime.episodes intValue] == 0) {
        cell.searchAnimeEpisodesLabel.text = [NSString stringWithFormat:@"Эпизоды: %@ / ?", anime.episodes_aired];
    } else {
        cell.searchAnimeEpisodesLabel.text = [NSString stringWithFormat:@"Эпизоды: %@", anime.episodes];
    }
    
    if ([anime.kind isEqualToString:@"tv"]) {
        anime.kind = @"TV сериал";
    }
    
    if ([anime.kind isEqualToString:@"movie"]) {
        anime.kind = @"Фильм";
    }
    
    if ([anime.status isEqualToString:@"released"]) {
        anime.status = @"Статус: Вышло";
    } else if ([anime.status isEqualToString:@"ongoing"]) {
        anime.status = @"Статус: Онгоинг";
    }
    
    cell.searchAnimeTypeLabel.text = anime.kind;
    cell.searchAnimeStatusLabel.text = anime.status;
    
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://shikimori.org%@", anime.imageURL]]];
    __weak AAAnimeSearchTableViewCell* weakCell = cell;
    
    [cell.searchAnimeImageView
     setImageWithURLRequest:request
     placeholderImage:self.placeholder
     success:^(NSURLRequest * request, NSHTTPURLResponse *response, UIImage *image) {
         weakCell.searchAnimeImageView.image = image;
         [weakCell layoutSubviews];
     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
         NSLog(@"%@", error);
     }];
    
    CALayer *cellImageLayer = cell.searchAnimeImageView.layer;
    [cellImageLayer setCornerRadius:4];
    [cellImageLayer setMasksToBounds:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo name];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self.fetchedResultsController sectionIndexTitles];
}

- (NSString *)controller:(NSFetchedResultsController *)controller sectionIndexTitleForSectionName:(NSString *)sectionName {
    return sectionName;
}

#pragma mark - NSFetchedResultsController

- (NSFetchedResultsController*)filter:(NSString*)text {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                       
                       NSEntityDescription *entity = [NSEntityDescription entityForName:@"Anime" inManagedObjectContext:self.managedObjectContext];
                       
                       [fetchRequest setEntity:entity];
                       
                       [fetchRequest setFetchBatchSize:50];
                       
                       NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"firstLetterForSection" ascending:YES];
                       NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"russianName" ascending:YES];
                       
                       [fetchRequest setSortDescriptors:@[sortDescriptor1, sortDescriptor2]];
                       
                       if(text.length) {
                           
                           NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(russianName CONTAINS[c] %@) OR (englishName CONTAINS[c] %@)", text, text];
                           [fetchRequest setPredicate:predicate];
                       }
                       
                       self.fetchedResultsController  = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                            managedObjectContext:self.managedObjectContext
                                                                                              sectionNameKeyPath:@"firstLetterForSection"
                                                                                                       cacheName:nil];
                       self.fetchedResultsController.delegate = self;
                       
                       NSError *error = nil;
                       
                       if (![self.fetchedResultsController performFetch:&error]) {
                           NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                           abort();
                       }
                       dispatch_async(dispatch_get_main_queue(),
                                      ^{
                                          [self.tableView reloadData];
                                      });
                   });
    
    return _fetchedResultsController;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    searchBar.text = @"";
    [self filter:@""];
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self filter:searchText];
    if (searchText.length == 0) {
        [searchBar resignFirstResponder];
        [searchBar setShowsCancelButton:NO animated:YES];
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

#pragma mark - Navigation Methods

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    if ([[segue identifier] isEqualToString:@"profile"]) {
        Anime *anime = [self.fetchedResultsController objectAtIndexPath:indexPath];
        AAAnimeProfileViewController *destination1 = [segue destinationViewController];
        destination1.animeID = anime.animeID;
    }
}

@end
