//
//  AAAnimeCalendarViewCell.h
//  Shikimori
//
//  Created by Admin on 29.04.16.
//  Copyright © 2016 Arsen Avanesyan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AAAnimeCalendarViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *calendarAnimeImageView;
@property (weak, nonatomic) IBOutlet UILabel *calendarAnimeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *calendarAnimeNextEpisode;
@property (weak, nonatomic) IBOutlet UILabel *calendarAnimeType;

@end
