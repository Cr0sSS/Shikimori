//
//  AAAnimeProfile.m
//  Shikimori
//
//  Created by Admin on 30.03.16.
//  Copyright © 2016 Arsen Avanesyan. All rights reserved.
//

#import "AAAnimeProfile.h"

@interface AAAnimeProfile ()

@end

@implementation AAAnimeProfile

- (id)initWithServerResponce:(NSDictionary*) responseObject {
    self = [super init];
    if (self) {
        self.animeID = [responseObject objectForKey:@"id"];
        
        if (![[responseObject objectForKey:@"name"] isEqual:[NSNull null]]) {
            self.name = [responseObject objectForKey:@"name"];
        }
        
        if ([[responseObject objectForKey:@"russian"] isEqual:[NSNull null]]) {
            self.russian = [responseObject objectForKey:@"name"];
        } else {
            self.russian = [NSString stringWithFormat:@"%@ / %@", [responseObject objectForKey:@"russian"], self.name];
        }
        
        self.images = [responseObject objectForKey:@"image"];
        
        if (![[self.images objectForKey:@"original"] isEqual:[NSNull null]]) {
            self.imageURL = [self.images objectForKey:@"original"];
        }
        
        if ([[responseObject objectForKey:@"episodes_aired"] isEqual:[NSNull null]]) {
            self.episodesAired = @"?";
        } else {
            self.episodesAired = [responseObject objectForKey:@"episodes_aired"];
        }
        
        if ([[responseObject objectForKey:@"episodes"] isEqual:[NSNull null]]) {
            self.episodes = @"?";
        } else {
            self.episodes = [responseObject objectForKey:@"episodes"];
            NSInteger episodesInt = [self.episodes intValue];
            if (episodesInt == 0) {
                self.episodes = [NSString stringWithFormat:@"%@ / ?", self.episodesAired];
            }
        }
        
        if (![[responseObject objectForKey:@"duration"] isEqual:[NSNull null]]) {
            self.duration = [responseObject objectForKey:@"duration"];
            self.duration = [NSString stringWithFormat:@"%@ мин", self.duration];
            NSInteger durationInt = [self.duration intValue];
            if (durationInt == 0) {
                self.duration = @"Неизвестно";
            }
        }
        
        if ([[responseObject objectForKey:@"aired_on"] isEqual:[NSNull null]]) {
            self.airedOn = @"Неизвестно";
        } else {
            self.airedOn = [responseObject objectForKey:@"aired_on"];
            [self convertDateAiredOn];
        }
        
        self.score = [responseObject objectForKey:@"score"];
        if (![[responseObject objectForKey:@"status"] isEqual:[NSNull null]]) {
            self.status = [responseObject objectForKey:@"status"];
            if ([self.status isEqualToString:@"anons"]) {
                self.score = @"0.0";
            }
        }
        
        if ([[responseObject objectForKey:@"kind"] isEqual:[NSNull null]]) {
            self.kind = @"Неизвестно";
        } else {
            self.kind = [responseObject objectForKey:@"kind"];
            if ([self.kind isEqualToString:@"tv"]) {
                self.kind = @"TV сериал";
            } else if ([self.kind isEqualToString:@"movie"]) {
                self.kind = @"Фильм";
                self.releasedOn = self.airedOn;
            } else if ([self.kind isEqualToString:@"special"]) {
                self.releasedOn = self.airedOn;
            } else if ([self.kind isEqualToString:@"ova"] && self.releasedOn != 0) {
                
            } else if ([self.kind isEqualToString:@"ova"]) {
                self.releasedOn = self.airedOn;
            }
        }
        
        if ([self.status isEqualToString:@"anons"] && (![[responseObject objectForKey:@"aired_on"] isEqual:[NSNull null]])) {
            self.airedOn = [NSString stringWithFormat:@"Анонс на %@", self.airedOn];
            self.releasedOn = @"Неизвестно";
        } else if ([self.status isEqualToString:@"anons"]) {
            self.airedOn = @"Анонсировано";
            self.releasedOn = @"Неизвестно";
        }
        
        if ([[responseObject objectForKey:@"released_on"] isEqual:[NSNull null]]) {
            if ([self.status isEqualToString:@"ongoing"]) {
                self.releasedOn = @"Онгоинг";
            }
        } else {
            self.releasedOn = [responseObject objectForKey:@"released_on"];
            [self convertDateReleasedOn];
        }
        
        self.genres = [responseObject objectForKey:@"genres"];
        NSMutableArray *mArray = [NSMutableArray array];
        for (NSDictionary *genres in self.genres) {
            NSString *genre = genres[@"russian"];
            [mArray addObject:genre];
        }

        self.genre = [mArray componentsJoinedByString:@", "];
        
        if (![[responseObject objectForKey:@"description"] isEqual:[NSNull null]]) {
            self.descriptionAnime = [responseObject objectForKey:@"description"];
        }

    }
    return self;
}

- (void) convertDateAiredOn {
    NSString *dateString = self.airedOn;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:dateString];
    
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    NSString *stringDate = [dateFormatter stringFromDate:dateFromString];
    self.airedOn = stringDate;
}

-(void) convertDateReleasedOn {
    NSString *dateString = self.releasedOn;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:dateString];
    
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    NSString *stringDate = [dateFormatter stringFromDate:dateFromString];
    self.releasedOn = stringDate;
}

@end
