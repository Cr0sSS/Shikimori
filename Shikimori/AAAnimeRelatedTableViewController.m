//
//  AAAnimeRelatedTableViewController.m
//  Shikimori
//
//  Created by Admin on 09.04.16.
//  Copyright © 2016 Arsen Avanesyan. All rights reserved.
//

#import "AAAnimeRelatedTableViewController.h"
#import "AAServerManager.h"
#import "UIImageView+AFNetworking.h"
#import "AAAnimeRelatedTableViewCell.h"
#import "AAAnimeProfileViewController.h"
#import "SVProgressHUD.h"

@interface AAAnimeRelatedTableViewController ()

@property (strong, nonatomic) UIImage *placeholder;
@property (strong, nonatomic) AAAnimeProfile *animeProfile;

@end

@implementation AAAnimeRelatedTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [UIView new];
    
    self.related = [NSMutableArray array];
    self.relatedProfile = [NSMutableArray array];
    self.genres = [NSMutableArray array];
    
    if (IS_IPAD) {
        self.tableView.rowHeight = 240;
    } else {
        self.tableView.rowHeight = 120;
    }
    
    self.placeholder = [UIImage imageNamed:@"imageholder"];
    
    [self getAnimeRelatedFromServer];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) convertDate:(AAAnimeRelatedTableViewCell *)cell {
    if (!([self.animeProfile.status isEqualToString:@"anons"] && self.animeProfile.airedOn != 0)) {
        NSString *dateString = self.animeProfile.airedOn;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd-MM-yyyy"];
        NSDate *dateFromString = [[NSDate alloc] init];
        dateFromString = [dateFormatter dateFromString:dateString];
        [dateFormatter setDateFormat:@"yyyy"];
        NSString *stringDate = [dateFormatter stringFromDate:dateFromString];
        cell.relatedAnimeYearLabel.text = stringDate;
    } else {
        cell.relatedAnimeYearLabel.text = self.animeProfile.airedOn;
    }
}

#pragma mark - API Methods

- (void) getAnimeRelatedFromServer {

    [SVProgressHUD show];
    
    [[AAServerManager shareManager] getAnimeRelated:self.animeID
                                          onSuccess:^(NSArray *animeRelated) {
                                              [self.related addObjectsFromArray:animeRelated];
                                              if ([self.related count] == 0) {
                                                  [SVProgressHUD dismiss];
                                                  return YES;
                                              }
                                              
                                              dispatch_queue_t queue = dispatch_queue_create("com.shiki.related", DISPATCH_QUEUE_CONCURRENT);
                                              dispatch_async(queue, ^{
                                                  
                                                  dispatch_group_t group = dispatch_group_create();
                                                  
                                              for (AAAnimeRelated *anime in self.related) {
                                                  dispatch_group_enter(group);
                                                  [[AAServerManager shareManager] getAnimeProfile:anime.animeID
                                                                                        onSuccess:^(AAAnimeProfile *animeDateAndGenres) {
                                                                                            [self.relatedProfile addObject:animeDateAndGenres];
                                                                                            dispatch_group_leave(group);
                                                                                        }
                                                                                        onFailure:^(NSError *error, NSInteger statusCode) {
                                                                                            NSLog(@"error = %@, code = %ld", [error localizedDescription], (long)statusCode);
                                                                                            dispatch_group_leave(group);
                                                                                        }];
                                                   dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
                                              }
                                                  dispatch_group_notify(group, dispatch_get_main_queue(), ^{
                                                      [self.tableView reloadData];
                                                      [SVProgressHUD dismiss];
                                                  });
                                                  
                                              });
                                              return YES;
                                          }
                                          onFailure:^(NSError *error, NSInteger statusCode) {
                                              [SVProgressHUD dismiss];
                                          }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.relatedProfile count];
}

- (AAAnimeRelatedTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const reuseIdentifier = @"Cell";
    AAAnimeRelatedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[AAAnimeRelatedTableViewCell alloc] init];
    }
    
    self.animeProfile = [self.relatedProfile objectAtIndex:indexPath.row];
    AAAnimeRelated *animeRelated = [self.related objectAtIndex:indexPath.row];
    
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://shikimori.org%@", self.animeProfile.imageURL]]];
    
    __weak AAAnimeRelatedTableViewCell* weakCell = cell;
    
    [cell.relatedAnimeImageView
     setImageWithURLRequest:request
     placeholderImage:self.placeholder
     success:^(NSURLRequest * request, NSHTTPURLResponse *response, UIImage *image) {
         weakCell.relatedAnimeImageView.image = image;
         [weakCell layoutSubviews];
     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
         NSLog(@"%@", error);
     }];
    
    [self convertDate:cell];
    
    cell.relatedAnimeNameLabel.text = [NSString stringWithFormat:@"%@", self.animeProfile.russian];
    cell.relatedAnimeTypeLabel.text = [NSString stringWithFormat:@"%@", self.animeProfile.kind];
    cell.relatedAnimeEpisodesLabel.text = [NSString stringWithFormat:@"Эпизоды: %@", self.animeProfile.episodes];
    cell.relatedAnimeGenresLabel.text = [NSString stringWithFormat:@"%@", self.animeProfile.genre];
    cell.relatedAnimeRelationLabel.text = [NSString stringWithFormat:@"%@", animeRelated.relationRussian];
    
    cell.relatedAnimeNameLabel.textColor = [UIColor colorWithRed:25/255.0 green:181/255.0 blue:254/255.0 alpha:1];
    
    CALayer *cellImageLayer = cell.relatedAnimeImageView.layer;
    [cellImageLayer setCornerRadius:4];
    [cellImageLayer setMasksToBounds:YES];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation Methods

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    
    if ([[segue identifier] isEqualToString:@"ShowAnimeProfile"]) {
        
        AAAnimeProfile *anime = [self.relatedProfile objectAtIndex:indexPath.row];
        AAAnimeProfileViewController *destination1 = [segue destinationViewController];
        destination1.animeID = anime.animeID;
    }
}

@end
