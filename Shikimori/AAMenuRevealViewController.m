//
//  AAMenuRevealViewController.m
//  Shikimori
//
//  Created by Admin on 28.04.16.
//  Copyright © 2016 Arsen Avanesyan. All rights reserved.
//

#import "AAMenuRevealViewController.h"
#import "SWRevealViewController.h"
#import "AACatalogCollectionViewController.h"
#import "AACalendarTableViewController.h"

@interface AAMenuRevealViewController ()

@end

@implementation AAMenuRevealViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Меню";
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:25/255.0 green:181/255.0 blue:254/255.0 alpha:1];
    self.tableView.separatorColor = [UIColor clearColor];
    
    self.tableView.scrollEnabled = NO;
    self.clearsSelectionOnViewWillAppear = NO;
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:1.0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 5;
    } else if (section == 1) {
        return 1;
    } else {
        return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"   Каталог";
    } else if (section == 1) {
        return @"   Календарь";
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    NSString *text = nil;
    if (indexPath.section == 0) {
        switch (indexPath.row)
        {
            case 0: text = @"Весь список"; break;
            case 1: text = @"Анонсировано"; break;
            case 2: text = @"Сейчас идёт"; break;
            case 3: text = @"Вышедшее"; break;
            case 4: text = @"Недавно вышедшее"; break;
        }
    } else if (indexPath.section == 1) {
        text = @"Календарь онгоингов";
    }
    
    cell.imageView.image = [UIImage imageNamed:text];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.font =  [UIFont fontWithName:@"Copperplate" size:17.0];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = text;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(0, 0, self.view.bounds.size.width, 28);
    myLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
    myLabel.font = [UIFont fontWithName:@"Copperplate" size:19.0];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    myLabel.backgroundColor = [UIColor colorWithRed:163/255.0f green:163/255.0f blue:163/255.0f alpha:1.0f];
    
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:myLabel];
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SWRevealViewController *revealController = self.revealViewController;
    
    if (indexPath.section == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        AACatalogCollectionViewController *catalogController = [storyboard  instantiateViewControllerWithIdentifier:@"CollectionViewController"];
        
        if (indexPath.row == 0) {
            catalogController.order = @"ranked";
            catalogController.status = @"";
        } else if (indexPath.row == 1) {
            catalogController.order = @"";
            catalogController.status = @"anons";
        } else if (indexPath.row == 2) {
            catalogController.order = @"";
            catalogController.status = @"ongoing";
        } else if (indexPath.row == 3) {
            catalogController.order = @"";
            catalogController.status = @"released";
        } else if (indexPath.row == 4) {
            catalogController.order = @"";
            catalogController.status = @"latest";
        }
        
        UINavigationController *frontNavigationController = [[UINavigationController alloc] initWithRootViewController:catalogController];
        
        [revealController setFrontViewController:frontNavigationController animated:YES];
        [revealController setFrontViewPosition:FrontViewPositionLeft animated:YES];
        
    } else if (indexPath.section == 1) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        AACalendarTableViewController *calendarController = [storyboard  instantiateViewControllerWithIdentifier:@"CalendarTableView"];

        UINavigationController *frontNavigationController = [[UINavigationController alloc] initWithRootViewController:calendarController];
        
        [revealController setFrontViewController:frontNavigationController animated:YES];
        [revealController setFrontViewPosition:FrontViewPositionLeft animated:YES];
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
