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

@property (strong, nonatomic) NSString *genres;
@property (strong, nonatomic) UIImage *placeholder;
@property (strong, nonatomic) AAAnimeProfile *animeProfile;

@end

@implementation AAAnimeRelatedTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.animeRelatedArray = [NSMutableArray array];
    self.animeRelatedProfileArray = [NSMutableArray array];
    self.genresStringArray = [NSMutableArray array];
    
    self.placeholder = [UIImage imageNamed:@"imageholder"];
    
    [self getAnimeRelatedFromServer];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) convertDate:(AAAnimeRelatedTableViewCell *)cell {
    NSString *dateString = self.animeProfile.airedOn;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:dateString];
    
    [dateFormatter setDateFormat:@"yyyy"];
    NSString *stringDate = [dateFormatter stringFromDate:dateFromString];
    cell.relatedAnimeYearLabel.text = stringDate;
    if ([self.animeProfile.status isEqualToString:@"anons"] && self.animeProfile.airedOn != 0) {
        cell.relatedAnimeYearLabel.text = self.animeProfile.airedOn;
    } else if ([self.animeProfile.status isEqualToString:@"anons"]) {
        self.animeProfile.airedOn = @"Анонсировано";
        cell.relatedAnimeYearLabel.text = self.animeProfile.airedOn;
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

- (void) setCALayerForImage:(AAAnimeRelatedTableViewCell *)cell {
    CALayer *cellImageLayer = cell.relatedAnimeImageView.layer;
    [cellImageLayer setCornerRadius:4];
    [cellImageLayer setMasksToBounds:YES];
}

#pragma mark - API Methods

- (void) getAnimeRelatedFromServer {
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    [blurEffectView setFrame:self.view.frame];
    [self.view addSubview:blurEffectView];
    
    [SVProgressHUD show];
    
    [[AAServerManager shareManager] getAnimeRelated:self.animeID
                                          onSuccess:^(NSArray *animeRelated) {
                                              [self.animeRelatedArray addObjectsFromArray:animeRelated];
                                              if ([self.animeRelatedArray count] == 0) {
                                                  [SVProgressHUD dismiss];
                                                  [blurEffectView removeFromSuperview];
                                              }
                                              for (AAAnimeRelated *anime in self.animeRelatedArray) {
                                                  [[AAServerManager shareManager] getAnimeProfile:anime.animeID
                                                                                        onSuccess:^(AAAnimeProfile *animeDateAndGenres) {
                                                                                            [self.animeRelatedProfileArray addObject:animeDateAndGenres];
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
                                              [blurEffectView removeFromSuperview];
                                              [SVProgressHUD dismiss];
                                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка"
                                                                                              message:@"Не удалось подключиться к серверу. Попробовать еще раз?"
                                                                                             delegate:self
                                                                                    cancelButtonTitle:@"Нет"
                                                                                    otherButtonTitles:@"Да", nil];
                                              [alert show];
                                          }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.animeRelatedProfileArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const reuseIdentifier = @"Cell";
    AAAnimeRelatedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[AAAnimeRelatedTableViewCell alloc] init];
    }
    
    self.animeProfile = [self.animeRelatedProfileArray objectAtIndex:indexPath.row];
    AAAnimeRelated *animeRelated = [self.animeRelatedArray objectAtIndex:indexPath.row];
    
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
    
    [self parseAnimeGenres];
    [self convertDate:cell];
    [self setCALayerForImage:cell];
    
    cell.relatedAnimeNameLabel.text = [NSString stringWithFormat:@"%@", self.animeProfile.russian];
    cell.relatedAnimeTypeLabel.text = [NSString stringWithFormat:@"%@", self.animeProfile.kind];
    cell.relatedAnimeEpisodesLabel.text = [NSString stringWithFormat:@"Эпизоды: %@", self.animeProfile.episodes];
    cell.relatedAnimeGenresLabel.text = [NSString stringWithFormat:@"%@", self.genres];
    cell.relatedAnimeRelationLabel.text = [NSString stringWithFormat:@"%@", animeRelated.relationRussian];
    
    cell.relatedAnimeNameLabel.textColor = [UIColor colorWithRed:25/255.0 green:181/255.0 blue:254/255.0 alpha:1];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"Да"]) {
        [self getAnimeRelatedFromServer];
    }
}

#pragma mark - Navigation Methods

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    
    if ([[segue identifier] isEqualToString:@"ShowAnimeProfile"]) {
        
        AAAnimeProfile *anime = [self.animeRelatedProfileArray objectAtIndex:indexPath.row];
        AAAnimeProfileViewController *destination1 = [segue destinationViewController];
        destination1.animeID = anime.animeID;
    }
}

@end
