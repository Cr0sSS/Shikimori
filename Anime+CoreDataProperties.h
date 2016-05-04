//
//  Anime+CoreDataProperties.h
//  Shikimori
//
//  Created by Admin on 19.04.16.
//  Copyright © 2016 Arsen Avanesyan. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Anime.h"

NS_ASSUME_NONNULL_BEGIN

@interface Anime (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *animeID;
@property (nullable, nonatomic, retain) NSString *englishName;
@property (nullable, nonatomic, retain) NSString *episodes;
@property (nullable, nonatomic, retain) NSString *ongoing;
@property (nullable, nonatomic, retain) NSString *imageURL;
@property (nullable, nonatomic, retain) NSString *kind;
@property (nullable, nonatomic, retain) NSString *russianName;
@property (nullable, nonatomic, retain) NSString *episodes_aired;
@property (nullable, nonatomic, retain) NSString *anons;
@property (nullable, nonatomic, retain) NSString *status;
@property (nullable, nonatomic, retain) NSString *firstLetterForSection;

@end

NS_ASSUME_NONNULL_END
