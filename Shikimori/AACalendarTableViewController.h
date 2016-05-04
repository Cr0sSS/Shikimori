//
//  AACalendarTableViewController.h
//  Shikimori
//
//  Created by Admin on 29.04.16.
//  Copyright © 2016 Arsen Avanesyan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AACalendarTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray *animeArray;

@end
