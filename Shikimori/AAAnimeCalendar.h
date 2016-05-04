//
//  AAAnimeCalendar.h
//  Shikimori
//
//  Created by Admin on 29.04.16.
//  Copyright © 2016 Arsen Avanesyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AAAnimeCalendar : NSObject

@property (strong, nonatomic) NSString *nextEpisode;
@property (strong, nonatomic) NSString *nextEpisodeAt;
@property (strong, nonatomic) NSString *duration;
@property (strong, nonatomic) NSDictionary* anime;
@property (strong, nonatomic) NSString *animeID;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *russian;
@property (strong, nonatomic) NSDictionary *imageDict;
@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSString *kind;
@property (strong, nonatomic) NSString *ongoing;
@property (strong, nonatomic) NSString *anons;
@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NSString *episodes;
@property (strong, nonatomic) NSString *episodesAired;

- (id)initWithServerResponce:(NSDictionary*) responseObject;

@end
