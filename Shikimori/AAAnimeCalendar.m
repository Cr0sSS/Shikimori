//
//  AAAnimeCalendar.m
//  Shikimori
//
//  Created by Admin on 29.04.16.
//  Copyright © 2016 Arsen Avanesyan. All rights reserved.
//

#import "AAAnimeCalendar.h"

@implementation AAAnimeCalendar

- (id)initWithServerResponce:(NSDictionary*) responseObject {
    self = [super init];
    if (self) {
        self.anime = [responseObject objectForKey:@"anime"];
        
        self.animeID = [self.anime objectForKey:@"id"];
        
        self.imageDict = [self.anime objectForKey:@"image"];
        self.imageURL = [self.imageDict objectForKey:@"original"];
        
        if (![[self.anime objectForKey:@"russian"] isEqual:[NSNull null]]) {
            self.russian = [self.anime objectForKey:@"russian"];
        } else {
            self.russian = [self.anime objectForKey:@"name"];
        }
        
        self.nextEpisode = [responseObject objectForKey:@"next_episode"];
        
        NSString *nextEpisodeAt = [responseObject objectForKey:@"next_episode_at"];
        

        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ru_RU"];
        
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS+zz:zz";
        
        NSDate *yourDate = [dateFormatter dateFromString:nextEpisodeAt];

        dateFormatter.dateFormat = @"d MMMM, EEEE";
        self.nextEpisodeAt = [dateFormatter stringFromDate:yourDate];
    }
    return self;
}



@end
