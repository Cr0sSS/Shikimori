//
//  AAAnimeRelatedTableViewController.h
//  Shikimori
//
//  Created by Admin on 09.04.16.
//  Copyright © 2016 Arsen Avanesyan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AAAnimeRelatedTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSString *animeID;
@property (strong, nonatomic) NSMutableArray *animeRelatedArray;
@property (strong, nonatomic) NSMutableArray *animeRelatedProfileArray;
@property (strong, nonatomic) NSMutableArray *genresStringArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
