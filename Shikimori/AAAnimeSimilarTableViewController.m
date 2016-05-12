//
//  AAAnimeSimilarTableViewController.m
//  Shikimori
//
//  Created by Admin on 08.04.16.
//  Copyright © 2016 Arsen Avanesyan. All rights reserved.
//

#import "AAAnimeSimilarTableViewController.h"
#import "AAServerManager.h"
#import "UIImageView+AFNetworking.h"
#import "AAAnimeSimilarTableViewCell.h"
#import "AAAnimeProfileViewController.h"
#import "SVProgressHUD.h"

@interface AAAnimeSimilarTableViewController ()

@property (strong, nonatomic) UIImage *placeholder;
@property (strong, nonatomic) AAAnimeProfile *animeProfile;

@end

@implementation AAAnimeSimilarTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [UIView new];
    
    self.similar = [NSMutableArray array];
    self.similarProfile = [NSMutableArray array];
    self.genres = [NSMutableArray array];
    
    if (IS_IPAD) {
        self.tableView.rowHeight = 240;
    } else {
        self.tableView.rowHeight = 120;
    }
    
    self.placeholder = [UIImage imageNamed:@"imageholder"];
    
    [self getAnimeSimilarFromServer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) convertDate:(AAAnimeSimilarTableViewCell*) cell {
    if (!([self.animeProfile.status isEqualToString:@"anons"] && self.animeProfile.airedOn != 0)) {
        NSString *dateString = self.animeProfile.airedOn;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd-MM-yyyy"];
        NSDate *dateFromString = [[NSDate alloc] init];
        dateFromString = [dateFormatter dateFromString:dateString];
        [dateFormatter setDateFormat:@"yyyy"];
        NSString *stringDate = [dateFormatter stringFromDate:dateFromString];
        cell.similarAnimeYearLabel.text = stringDate;
    } else {
        cell.similarAnimeYearLabel.text = self.animeProfile.airedOn;
    }
}

#pragma mark - API Methods

- (void) getAnimeSimilarFromServer {
    [SVProgressHUD show];
    [[AAServerManager shareManager] getAnimeSimilar:self.animeID
                                          onSuccess:^(NSArray *animeSimilar) {
                                              [self.similar addObjectsFromArray:animeSimilar];
                                              if ([self.similar count] == 0) {
                                                  [SVProgressHUD dismiss];
                                                  return YES;
                                              }
                                              
                                              dispatch_queue_t queue = dispatch_queue_create("com.shiki.similar", DISPATCH_QUEUE_CONCURRENT);
                                              dispatch_async(queue, ^{
                                                  
                                                  dispatch_group_t group = dispatch_group_create();
                                                  
                                                  for (AAAnimeSimilar *anime in self.similar){
                                                      dispatch_group_enter(group);
                                                      [[AAServerManager shareManager] getAnimeProfile:anime.animeID
                                                                                            onSuccess:^(AAAnimeProfile *animeDateAndGenres) {
                                                                                                [self.similarProfile addObject:animeDateAndGenres];
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

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.similarProfile count];
}

- (AAAnimeSimilarTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const reuseIdentifier = @"Cell";
    AAAnimeSimilarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[AAAnimeSimilarTableViewCell alloc] init];
    }
    
    self.animeProfile = [self.similarProfile objectAtIndex:indexPath.row];
    
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://shikimori.org%@", self.animeProfile.imageURL]]];
    
    __weak AAAnimeSimilarTableViewCell* weakCell = cell;
    
    [cell.similarAnimeImageView
     setImageWithURLRequest:request
     placeholderImage:self.placeholder
     success:^(NSURLRequest * request, NSHTTPURLResponse *response, UIImage *image) {
         weakCell.similarAnimeImageView.image = image;
         [weakCell layoutSubviews];
     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
         NSLog(@"%@", error);
     }];
    
    [self convertDate:cell];
    
    cell.similarAnimeNameLabel.text = [NSString stringWithFormat:@"%@", self.animeProfile.russian];
    cell.similarAnimeTypeLabel.text = [NSString stringWithFormat:@"%@", self.animeProfile.kind];
    cell.similarAnimeEpisodesLabel.text = [NSString stringWithFormat:@"Эпизоды: %@", self.animeProfile.episodes];
    cell.similarAnimeGenresLabel.text = [NSString stringWithFormat:@"%@", self.animeProfile.genre];
    
    cell.similarAnimeNameLabel.textColor = [UIColor colorWithRed:25/255.0 green:181/255.0 blue:254/255.0 alpha:1];
    
    CALayer *cellImageLayer = cell.similarAnimeImageView.layer;
    [cellImageLayer setCornerRadius:4];
    [cellImageLayer setMasksToBounds:YES];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"Да"]) {
        [self getAnimeSimilarFromServer];
    }
}

#pragma mark - Navigation Methods

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    if ([[segue identifier] isEqualToString:@"ShowAnimeProfile"]) {
        
        AAAnimeProfile *anime = [self.similarProfile objectAtIndex:indexPath.row];
        AAAnimeProfileViewController *destination1 = [segue destinationViewController];
        destination1.animeID = anime.animeID;
    }
}

@end
