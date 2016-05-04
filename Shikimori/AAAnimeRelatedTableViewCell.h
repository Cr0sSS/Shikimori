//
//  AAAnimeRelatedTableViewCell.h
//  Shikimori
//
//  Created by Admin on 13.04.16.
//  Copyright © 2016 Arsen Avanesyan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AAAnimeRelatedTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *relatedAnimeImageView;
@property (weak, nonatomic) IBOutlet UILabel *relatedAnimeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *relatedAnimeGenresLabel;
@property (weak, nonatomic) IBOutlet UILabel *relatedAnimeYearLabel;
@property (weak, nonatomic) IBOutlet UILabel *relatedAnimeTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *relatedAnimeEpisodesLabel;
@property (weak, nonatomic) IBOutlet UILabel *relatedAnimeRelationLabel;

@end
