//
//  AASearchAnimeTableViewController.h
//  Shikimori
//
//  Created by Admin on 17.04.16.
//  Copyright © 2016 Arsen Avanesyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AACoreDataManager.h"


@interface AAAnimeSearchTableViewController : UIViewController <NSFetchedResultsControllerDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;



@end
