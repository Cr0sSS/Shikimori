//
//  AAAnimeList.m
//  Shikimori
//
//  Created by Admin on 30.03.16.
//  Copyright © 2016 Arsen Avanesyan. All rights reserved.
//

#import "AAAnimeCatalog.h"
#import "Anime+CoreDataProperties.h"

@implementation AAAnimeCatalog

- (id)initWithServerResponce:(NSDictionary*) responseObject
{
    self = [super init];
    if (self) {
        
        self.animeID = [responseObject objectForKey:@"id"];
        self.name = [responseObject objectForKey:@"name"];
        self.dict = [responseObject objectForKey:@"image"];
        self.imageURL = [self.dict objectForKey:@"original"];
        self.kind = [responseObject objectForKey:@"kind"];
        self.ongoing = [responseObject objectForKey:@"ongoing"];
        self.anons = [responseObject objectForKey:@"anons"];
        self.status = [responseObject objectForKey:@"status"];
        self.episodes = [responseObject objectForKey:@"episodes"];
        self.episodesAired = [responseObject objectForKey:@"episodes_aired"];
        
        if (![[responseObject objectForKey:@"russian"] isEqual:[NSNull null]]) {
            self.russian = [responseObject objectForKey:@"russian"];
        } else {
            self.russian = [responseObject objectForKey:@"name"];
        }
        
        if (![[responseObject objectForKey:@"name"] isEqual:[NSNull null]]) {
            self.name = [responseObject objectForKey:@"name"];
        } 
    }
    
    return self;
}

@end
