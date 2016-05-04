//
//  AASimilarPopUpTableViewController.m
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

@property (strong, nonatomic) NSString *genres;
@property (strong, nonatomic) UIImage *placeholder;
@property (strong, nonatomic) AAAnimeProfile *animeProfile;

@end

@implementation AAAnimeSimilarTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.animeSimilarArray = [NSMutableArray array];
    self.animeSimilarProfileArray = [NSMutableArray array];
    self.genresStringArray = [NSMutableArray array];
    
    [self getAnimeSimilarFromServer];
    
    self.placeholder = [UIImage imageNamed:@"imageholder"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - API Methods

- (void) getAnimeSimilarFromServer {
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    [blurEffectView setFrame:self.view.frame];
    [self.view addSubview:blurEffectView];
    
    [SVProgressHUD show];
    
    [[AAServerManager shareManager] getAnimeSimilar:self.animeID
                                          onSuccess:^(NSArray *animeSimilar) {
                                              [self.animeSimilarArray addObjectsFromArray:animeSimilar];
                                              if ([self.animeSimilarArray count] == 0) {
                                                  [SVProgressHUD dismiss];
                                                  [blurEffectView removeFromSuperview];
                                              }
                                              for (AAAnimeSimilar *anime in self.animeSimilarArray){
                                                  [[AAServerManager shareManager] getAnimeProfile:anime.animeID
                                                                                        onSuccess:^(AAAnimeProfile *animeDateAndGenres) { // переделать, и в релейтед тоже.
                                                                                            [self.animeSimilarProfileArray addObject:animeDateAndGenres];
                                                                                            
                                                                                            [self.tableView reloadData];
                                                                                            [SVProgressHUD dismiss];
                                                                                            [blurEffectView removeFromSuperview];
                                                                                        }
                                                                                        onFailure:^(NSError *error, NSInteger statusCode) {
                                                                                            NSLog(@"error = %@, code = %ld", [error localizedDescription], (long)statusCode);
                                                                                            [SVProgressHUD dismiss];
                                                                                            [blurEffectView removeFromSuperview];
                                                                                        }];
                                              }
                                          }
                                          onFailure:^(NSError *error, NSInteger statusCode) {
                                              NSLog(@"error = %@, code = %ld", [error localizedDescription], (long)statusCode);
                                              [SVProgressHUD dismiss];
                                              [blurEffectView removeFromSuperview];
                                          }];
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.animeSimilarProfileArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const reuseIdentifier = @"Cell";
    AAAnimeSimilarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[AAAnimeSimilarTableViewCell alloc] init];
    }
    
    self.animeProfile = [self.animeSimilarProfileArray objectAtIndex:indexPath.row];
    
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
    
    [self parseAnimeGenres];
    [self convertDate:cell];
    [self setCALayerForImage:cell];
    
    cell.similarAnimeNameLabel.text = [NSString stringWithFormat:@"%@", self.animeProfile.russian];
    cell.similarAnimeTypeLabel.text = [NSString stringWithFormat:@"%@", self.animeProfile.kind];
    cell.similarAnimeEpisodesLabel.text = [NSString stringWithFormat:@"Эпизоды: %@", self.animeProfile.episodes];
    cell.similarAnimeGenresLabel.text = [NSString stringWithFormat:@"%@", self.genres];
    
    cell.similarAnimeNameLabel.textColor = [UIColor colorWithRed:25/255.0 green:181/255.0 blue:254/255.0 alpha:1];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Methods

- (void) convertDate:(AAAnimeSimilarTableViewCell*) cell {
    NSString *dateString = self.animeProfile.airedOn;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:dateString];
    
    [dateFormatter setDateFormat:@"yyyy"];
    NSString *stringDate = [dateFormatter stringFromDate:dateFromString];
    cell.similarAnimeYearLabel.text = stringDate;
    if ([self.animeProfile.status isEqualToString:@"anons"] && self.animeProfile.airedOn != 0) {
        cell.similarAnimeYearLabel.text = self.animeProfile.airedOn;
    } else if ([self.animeProfile.status isEqualToString:@"anons"]) {
        self.animeProfile.airedOn = @"Анонсировано";
        cell.similarAnimeYearLabel.text = self.animeProfile.airedOn;
    }
}

- (void) parseAnimeGenres {
    for (NSDictionary *genres in self.animeProfile.genresArray) {
        self.animeProfile.genresRussian = genres[@"russian"];
        [self.genresStringArray addObject:self.animeProfile.genresRussian];
    }
    self.genres = [self.genresStringArray componentsJoinedByString:@", "];
    
    [self.genresStringArray removeAllObjects];
}

- (void) setCALayerForImage:(AAAnimeSimilarTableViewCell*) cell {
    CALayer *cellImageLayer = cell.similarAnimeImageView.layer;
    [cellImageLayer setCornerRadius:4];
    [cellImageLayer setMasksToBounds:YES];
}

#pragma mark - Navigation Methods

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    
    if ([[segue identifier] isEqualToString:@"ShowAnimeProfile"]) {
        
        AAAnimeProfile *anime = [self.animeSimilarProfileArray objectAtIndex:indexPath.row];
        AAAnimeProfileViewController *destination1 = [segue destinationViewController];
        destination1.animeID = anime.animeID;
    }
}

@end
