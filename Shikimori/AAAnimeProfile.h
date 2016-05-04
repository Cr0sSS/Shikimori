//
//  AAAnimeProfile.h
//  Shikimori
//
//  Created by Admin on 30.03.16.
//  Copyright © 2016 Arsen Avanesyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AAAnimeProfile : NSObject

@property (strong, nonatomic) NSString *animeID;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSDictionary *imageDict;
@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSString *kind;
@property (strong, nonatomic) NSString *episodes;
@property (strong, nonatomic) NSString *duration;
@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NSArray *genresArray;
@property (strong, nonatomic) NSString *genresRussian;
@property (strong, nonatomic) NSString *score;
@property (strong, nonatomic) NSString *airedOn;
@property (strong, nonatomic) NSString *releasedOn;
@property (strong, nonatomic) NSString *descriptionAnime;
@property (strong, nonatomic) NSString *episodesAired;
@property (strong, nonatomic) NSString *russian;

- (id)initWithServerResponce:(NSDictionary*) responseObject;
- (void) convertDateAiredOn;
-(void) convertDateReleasedOn;


@end
