//
//  AAAnimeProfileViewController.h
//  Shikimori
//
//  Created by Admin on 30.03.16.
//  Copyright © 2016 Arsen Avanesyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EDStarRating.h"

@interface AAAnimeProfileViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) NSString *animeID;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *animeProfileImage;
@property (weak, nonatomic) IBOutlet UITableView *informationTableView;
@property (weak, nonatomic) IBOutlet UILabel *animeNameTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *animeScoreTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *animeGradeTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *unchangeableRatingHeaderTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionHeaderTextLabel;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *profileButtons;
@property (weak, nonatomic) IBOutlet EDStarRating *starRating;


@end
