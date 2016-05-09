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

@property (strong, nonatomic) NSArray *informationArray;
@property (strong, nonatomic) NSMutableArray *genresStringArray;
@property (strong, nonatomic) AAAnimeProfile *animeProfile;
@property (strong, nonatomic) UIImage *placeholder;

@end

@implementation AAAnimeProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getAnimeProfileFromServer];
    
    self.informationArray = [NSArray arrayWithObjects:@"Тип:", @"Эпизоды:", @"Длительность эпизода:", @"Вышло:", @"Закончилось:", @"Жанры:", nil];
    
    for (UIButton *profileButton in self.profileButtons) {
        [[profileButton layer] setBorderWidth:0.8f];
        [[profileButton layer] setCornerRadius:6.0f];
        [[profileButton layer] setBorderColor:[UIColor colorWithRed:25/255.0 green:181/255.0 blue:254/255.0 alpha:1].CGColor];
        [[profileButton layer] setBackgroundColor:[UIColor colorWithRed:25/255.0 green:181/255.0 blue:254/255.0 alpha:1].CGColor];
    }

    self.descriptionTableView.allowsSelection = NO;
    self.informationTableView.allowsSelection = NO;
    
    self.placeholder = [UIImage imageNamed:@"imageholder"];
    
    _starRating.starImage = [[UIImage imageNamed:@"star-template"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _starRating.starHighlightedImage = [[UIImage imageNamed:@"star-highlighted-template"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    self.starRating.maxRating = 5.0;
    self.starRating.editable=YES;
    self.starRating.displayMode=EDStarRatingDisplayAccurate;
    

    self.unchangeableRatingHeaderTextLabel.backgroundColor = [UIColor colorWithRed:247/255.0f green:247/255.0f blue:247/255.0f alpha:1.0f];
    
    CALayer *animeImageLayer = self.animeProfileImage.layer;
    [animeImageLayer setCornerRadius:4];
    [animeImageLayer setMasksToBounds:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

- (void) downloadData {
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
}

#pragma mark - API Method

- (void) getAnimeProfileFromServer {
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    [blurEffectView setFrame:self.view.frame];
    [self.view addSubview:blurEffectView];
    
    [SVProgressHUD show];
    
    [[AAServerManager shareManager] getAnimeProfile:self.animeID onSuccess:^(AAAnimeProfile *animeProfile) {
        
        self.animeProfile = animeProfile;
        
        [self.informationTableView reloadData];
        [self.descriptionTableView reloadData];
        [self downloadData];
        [SVProgressHUD dismiss];
        [blurEffectView removeFromSuperview];
    } onFailure:^(NSError *error, NSInteger statusCode) {
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

#pragma mark <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.descriptionTableView) {
        return 1;
    } else
    return [self.informationArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.descriptionTableView) {
        return @"Описание";
    } else if (tableView == self.informationTableView) {
        return @"Информация";
    } else {
       return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const reuseIdentifier = @"Cell";
    AAAnimeProfileInformationViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (tableView == self.descriptionTableView && self.animeProfile != 0) {
       
        cell.textLabel.text = [NSString stringWithFormat:@"%@", self.animeProfile.descriptionAnime];
        cell.textLabel.numberOfLines = 0;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            UIFont *myFont =  [UIFont fontWithName:@"Copperplate" size:18.0];
            cell.textLabel.font  = myFont;
        } else {
            UIFont *myFont =  [UIFont fontWithName:@"Copperplate" size:10.0];
            cell.textLabel.font  = myFont;
        }
        
        return cell;
    }
    
    if (tableView == self.informationTableView && self.animeProfile != 0) {
        
        cell.customTextLabel.text = [self.informationArray objectAtIndex:indexPath.row];
        
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
            
            self.genresStringArray = [NSMutableArray array];
            
            for (NSDictionary *genres in self.animeProfile.genresArray) {
                self.animeProfile.genresRussian = genres[@"russian"];
                [self.genresStringArray addObject:self.animeProfile.genresRussian];
            }
            
            NSString *genresString = [self.genresStringArray componentsJoinedByString:@", "];
            
            cell.customDetailTextLabel.text = [NSString stringWithFormat:@"%@", genresString];
            cell.customDetailTextLabel.numberOfLines = 0;
        }
    }
    return cell;
}

#pragma mark <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (tableView == self.descriptionTableView) {
            self.descriptionTableView.estimatedRowHeight = 25;
            self.descriptionTableView.rowHeight = UITableViewAutomaticDimension;
            return self.descriptionTableView.rowHeight;
        } else {
            return 70;
        }
    } else {
        if (indexPath.row == 5) {
            return 30;
        } else if (tableView == self.descriptionTableView) {
            self.descriptionTableView.estimatedRowHeight = 25;
            self.descriptionTableView.rowHeight = UITableViewAutomaticDimension;
            return self.descriptionTableView.rowHeight;
        } else {
            return 24;
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == self.informationTableView) {
        UILabel *myLabel = [[UILabel alloc] init];
        myLabel.frame = CGRectMake(0, 0, self.view.bounds.size.width, 20);
        myLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
        myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
        myLabel.backgroundColor = [UIColor colorWithRed:247/255.0f green:247/255.0f blue:247/255.0f alpha:1.0f];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            myLabel.font = [UIFont fontWithName:@"Copperplate" size:22.0];
        } else {
            myLabel.font = [UIFont fontWithName:@"Copperplate" size:12.0];
        }
        
        UIView *headerView = [[UIView alloc] init];
        [headerView addSubview:myLabel];
        
        return headerView;
    } else if (tableView == self.descriptionTableView) {
        UILabel *myLabel = [[UILabel alloc] init];
        myLabel.frame = CGRectMake(0, 0, self.view.frame.size.width, 20);
        myLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
        myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
        myLabel.backgroundColor = [UIColor colorWithRed:247/255.0f green:247/255.0f blue:247/255.0f alpha:1.0f];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            myLabel.font = [UIFont fontWithName:@"Copperplate" size:22.0];
        } else {
            myLabel.font = [UIFont fontWithName:@"Copperplate" size:12.0];
        }
        
        UIView *headerView = [[UIView alloc] init];
        [headerView addSubview:myLabel];
        
        return headerView;
    } else {
        return nil;
    }
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


@end
