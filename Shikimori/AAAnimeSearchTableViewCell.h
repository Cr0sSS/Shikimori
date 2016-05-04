//
//  AAAnimeSearchTableViewCell.h
//  Shikimori
//
//  Created by Admin on 19.04.16.
//  Copyright © 2016 Arsen Avanesyan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AAAnimeSearchTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *searchAnimeImageView;
@property (weak, nonatomic) IBOutlet UILabel *searchAnimeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *searchAnimeStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *searchAnimeTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *searchAnimeEpisodesLabel;

@end
