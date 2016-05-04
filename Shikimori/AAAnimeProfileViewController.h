//
//  AAAnimeProfileViewController.h
//  Shikimori
//
//  Created by Admin on 30.03.16.
//  Copyright © 2016 Arsen Avanesyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EDStarRating.h"

@interface AAAnimeProfileViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSString *animeID;
@property (strong, nonatomic) NSArray *informationArray;
@property (strong, nonatomic) NSMutableArray *genresStringArray;
@property (weak, nonatomic) IBOutlet UIImageView *animeProfileImage;
@property (weak, nonatomic) IBOutlet UITableView *informationTableView;
@property (weak, nonatomic) IBOutlet UITableView *descriptionTableView;
@property (weak, nonatomic) IBOutlet UILabel *animeNameTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *animeScoreTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *animeGradeTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *unchangeableRatingHeaderTextLabel;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *profileButtons;
@property (weak, nonatomic) IBOutlet EDStarRating *starRating;


@end
