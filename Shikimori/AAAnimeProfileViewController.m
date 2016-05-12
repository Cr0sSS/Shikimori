//
//  AAAnimeProfileViewController.m
//  Shikimori
//
//  Created by Admin on 30.03.16.
//  Copyright © 2016 Arsen Avanesyan. All rights reserved.
//

#import "AAAnimeProfileViewController.h"
#import "AAServerManager.h"
#import "AAAnimeProfile.h"
#import "UIImageView+AFNetworking.h"
#import "AAAnimeVideoViewController.h"
#import "AAAnimeRelatedTableViewController.h"
#import "AAAnimeSimilarTableViewController.h"
#import "AAAnimeProfileInformationViewCell.h"
#import "SVProgressHUD.h"

@interface AAAnimeProfileViewController ()

@property (strong, nonatomic) NSArray *informations;
@property (strong, nonatomic) NSMutableArray *genres;
@property (strong, nonatomic) AAAnimeProfile *animeProfile;
@property (strong, nonatomic) UIImage *placeholder;
@property (strong, nonatomic) UILabel *descriptionTextLabel;

@end

@implementation AAAnimeProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getAnimeProfileFromServer];
    
    self.descriptionTextLabel = [[UILabel alloc] init];
    
    [self.scrollView addSubview:self.descriptionTextLabel];
    if (IS_IPHONE) {
        self.descriptionTextLabel.font = [UIFont fontWithName:@"Copperplate" size:10.0];
    } else {
        self.descriptionTextLabel.font = [UIFont fontWithName:@"Copperplate" size:18.0];
    }
    
    self.informations = @[@"Тип:", @"Эпизоды:", @"Длительность эпизода:", @"Вышло:", @"Закончилось:", @"Жанры:"];
    
    for (UIButton *profileButton in self.profileButtons) {
        [[profileButton layer] setBorderWidth:0.8f];
        [[profileButton layer] setCornerRadius:6.0f];
        [[profileButton layer] setBorderColor:[UIColor colorWithRed:25/255.0 green:181/255.0 blue:254/255.0 alpha:1].CGColor];
        [[profileButton layer] setBackgroundColor:[UIColor colorWithRed:25/255.0 green:181/255.0 blue:254/255.0 alpha:1].CGColor];
    }
    
    self.informationTableView.allowsSelection = NO;
    
    self.placeholder = [UIImage imageNamed:@"imageholder"];
    
    _starRating.starImage = [[UIImage imageNamed:@"star-template"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _starRating.starHighlightedImage = [[UIImage imageNamed:@"star-highlighted-template"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.starRating.maxRating = 5.0;
    self.starRating.editable=YES;
    self.starRating.displayMode=EDStarRatingDisplayAccurate;
    
    self.unchangeableRatingHeaderTextLabel.backgroundColor = [UIColor colorWithRed:247/255.0f green:247/255.0f blue:247/255.0f alpha:1.0f];
    self.descriptionHeaderTextLabel.backgroundColor = [UIColor colorWithRed:247/255.0f green:247/255.0f blue:247/255.0f alpha:1.0f];
    
    CALayer *animeImageLayer = self.animeProfileImage.layer;
    [animeImageLayer setCornerRadius:4];
    [animeImageLayer setMasksToBounds:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - API Method

- (void) getAnimeProfileFromServer {
    
    UIView *preloadView = [[UIView alloc] init];
    preloadView.backgroundColor = [UIColor whiteColor];
    preloadView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    [preloadView setFrame:self.view.frame];
    [self.view addSubview:preloadView];
    
    [SVProgressHUD show];
    
    [[AAServerManager shareManager] getAnimeProfile:self.animeID onSuccess:^(AAAnimeProfile *animeProfile) {
        
        self.animeProfile = animeProfile;
        
        [self downloadData];
        [self.informationTableView reloadData];
        [preloadView removeFromSuperview];
        [SVProgressHUD dismiss];
    } onFailure:^(NSError *error, NSInteger statusCode) {
        [preloadView removeFromSuperview];
        [SVProgressHUD dismiss];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка"
                                                        message:@"Не удалось получить данные. Попробовать еще раз?"
                                                       delegate:self
                                              cancelButtonTitle:@"Нет"
                                              otherButtonTitles:@"Да", nil];
        [alert show];
    }];
}

#pragma mark <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.informations count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Информация";
}

- (AAAnimeProfileInformationViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const reuseIdentifier = @"Cell";
    AAAnimeProfileInformationViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (self.animeProfile != 0) {
        
        cell.customTextLabel.text = [self.informations objectAtIndex:indexPath.row];
        
        if (indexPath.row == 0) {
            cell.customDetailTextLabel.text = [NSString stringWithFormat:@"%@", self.animeProfile.kind];
        }
        else if (indexPath.row == 1) {
            cell.customDetailTextLabel.text = [NSString stringWithFormat:@"%@", self.animeProfile.episodes];
        }
        else if (indexPath.row == 2) {
            cell.customDetailTextLabel.text = [NSString stringWithFormat:@"%@", self.animeProfile.duration];
        }
        else if (indexPath.row == 3) {
            cell.customDetailTextLabel.text = [NSString stringWithFormat:@"%@", self.animeProfile.airedOn];
        }
        else if (indexPath.row == 4) {
            cell.customDetailTextLabel.text = [NSString stringWithFormat:@"%@", self.animeProfile.releasedOn];
        }
        else if (indexPath.row == 5) {
            cell.customDetailTextLabel.text = self.animeProfile.genre;
            cell.customDetailTextLabel.numberOfLines = 0;
        }
    }
    return cell;
}

#pragma mark <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (IS_IPAD) {
        return 70;
    } else {
        if (indexPath.row == 5) {
            return 30;
        } else {
            return 24;
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *headerLabel = [[UILabel alloc] init];
    headerLabel.frame = CGRectMake(0, 0, self.view.bounds.size.width, 20);
    headerLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
    headerLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    headerLabel.backgroundColor = [UIColor colorWithRed:247/255.0f green:247/255.0f blue:247/255.0f alpha:1.0f];
    
    if (IS_IPAD) {
        headerLabel.font = [UIFont fontWithName:@"Copperplate" size:22.0];
    } else {
        headerLabel.font = [UIFont fontWithName:@"Copperplate" size:12.0];
    }
    
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:headerLabel];
    
    return headerView;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Да"]) {
        [self getAnimeProfileFromServer];
    }
}

#pragma mark - Navigation Methods

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"WatchVideo"]) {
        
        AAAnimeVideoViewController *vc = [segue destinationViewController];
        vc.animeID = self.animeID;
    } else if ([[segue identifier] isEqualToString:@"ShowSimilarAnime"]) {
        
        AAAnimeRelatedTableViewController *vc = [segue destinationViewController];
        vc.animeID = self.animeID;
    } else if ([[segue identifier] isEqualToString:@"ShowRelatedAnime"]) {
        
        AAAnimeRelatedTableViewController *vc = [segue destinationViewController];
        vc.animeID = self.animeID;
    }
}

#pragma mark - Another Methods

- (void)setScoreRating {
    float scoreFloat = [self.animeProfile.score floatValue];
    if (scoreFloat >= 9.0) {
        self.animeGradeTextLabel.text = @"Великолепно";
    } else if (scoreFloat >= 8.0) {
        self.animeGradeTextLabel.text = @"Отлично";
    } else if (scoreFloat >= 7.0) {
        self.animeGradeTextLabel.text = @"Хорошо";
    } else if (scoreFloat >= 6.0) {
        self.animeGradeTextLabel.text = @"Нормально";
    } else if (scoreFloat >= 5.0) {
        self.animeGradeTextLabel.text = @"Более-менее";
    } else if (scoreFloat >= 4.0) {
        self.animeGradeTextLabel.text = @"Плохо";
    } else if ([self.animeProfile.status isEqualToString:@"anons"]) {
        self.animeGradeTextLabel.text = @"Без оценки";
    } else if (scoreFloat == 0.0) {
        self.animeGradeTextLabel.text = @"Без оценки";
    } else  {
        self.animeGradeTextLabel.text = @"Ужасно";
    }
    
    self.starRating.rating = scoreFloat / 2;
}

- (void)downloadData {
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://shikimori.org%@", self.animeProfile.imageURL]]];
    [self.animeProfileImage
     setImageWithURLRequest:request
     placeholderImage:self.placeholder
     success:^(NSURLRequest * request, NSHTTPURLResponse *response, UIImage *image) {
         self.animeProfileImage.image = image;
     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
         NSLog(@"%@", error);
     }];
    
    [self setScoreRating];
    
    self.animeScoreTextLabel.text = self.animeProfile.score;
    self.animeNameTextLabel.text = self.animeProfile.russian;
    self.descriptionTextLabel.text = self.animeProfile.descriptionAnime;
    self.descriptionTextLabel.numberOfLines = 0;
    
    [self getScrollViewHeight];
}

- (void)getScrollViewHeight {
    if (IS_IPHONE) {
        
        [self.descriptionTextLabel setFrame:CGRectMake(16, self.descriptionHeaderTextLabel.frame.origin.y + self.descriptionHeaderTextLabel.frame.size.height +8, self.view.frame.size.width - 32, 0)];
        
        CGSize constraint = CGSizeMake(self.descriptionTextLabel.frame.size.width, 0);
        CGSize size;
        
        NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
        CGSize boundingBox = [self.descriptionTextLabel.text boundingRectWithSize:constraint
                                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                                       attributes:@{NSFontAttributeName:self.descriptionTextLabel.font}
                                                                          context:context].size;
        
        size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
        
        [self.descriptionTextLabel setFrame:CGRectMake(16, self.descriptionHeaderTextLabel.frame.origin.y + self.descriptionHeaderTextLabel.frame.size.height +8, self.view.frame.size.width - 32, size.height)];
        
        [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width - 16, self.descriptionHeaderTextLabel.frame.origin.y + self.descriptionHeaderTextLabel.frame.size.height +8 + size.height + 16)];
        
    } else {
        
        [self.descriptionTextLabel setFrame:CGRectMake(32, self.descriptionHeaderTextLabel.frame.origin.y + self.descriptionHeaderTextLabel.frame.size.height +16, self.view.frame.size.width - 64, 0)];
        
        CGSize constraint = CGSizeMake(self.descriptionTextLabel.frame.size.width, 0);
        CGSize size;
        
        NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
        CGSize boundingBox = [self.descriptionTextLabel.text boundingRectWithSize:constraint
                                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                                       attributes:@{NSFontAttributeName:self.descriptionTextLabel.font}
                                                                          context:context].size;
        
        size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
        
        [self.descriptionTextLabel setFrame:CGRectMake(32, self.descriptionHeaderTextLabel.frame.origin.y + self.descriptionHeaderTextLabel.frame.size.height +16, self.view.frame.size.width - 64, size.height)];
        
        [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width - 32, self.descriptionHeaderTextLabel.frame.origin.y + self.descriptionHeaderTextLabel.frame.size.height +16 + size.height + 32)];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self getScrollViewHeight];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
    }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

@end
