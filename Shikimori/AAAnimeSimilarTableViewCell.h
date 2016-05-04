//
//  AAAnimeSimilarTableViewCell.h
//  Shikimori
//
//  Created by Admin on 09.04.16.
//  Copyright © 2016 Arsen Avanesyan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AAAnimeSimilarTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *similarAnimeImageView;
@property (weak, nonatomic) IBOutlet UILabel *similarAnimeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *similarAnimeGenresLabel;
@property (weak, nonatomic) IBOutlet UILabel *similarAnimeYearLabel;
@property (weak, nonatomic) IBOutlet UILabel *similarAnimeTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *similarAnimeEpisodesLabel;

@end
