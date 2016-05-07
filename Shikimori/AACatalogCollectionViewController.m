//
//  AACollectionViewController.m
//  Shikimori
//
//  Created by Admin on 30.03.16.
//  Copyright © 2016 Arsen Avanesyan. All rights reserved.
//

#import "AACatalogCollectionViewController.h"
#import "AAServerManager.h"
#import "AAAnimeCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "AAAnimeProfileViewController.h"
#import "SVProgressHUD.h"
#import "SWRevealViewController.h"
#import "RWDropdownMenu.h"

@interface AACatalogCollectionViewController ()

@property (strong, nonatomic) NSMutableArray *animeArray;
@property (strong, nonatomic) NSMutableArray *addPaths;
@property (strong, nonatomic) UIImage *placeholder;
@property (assign, nonatomic) BOOL loadingCell;
@property (strong, nonatomic) UIButton *titleButton;
@property (strong, nonatomic) UIVisualEffectView *blurEffectView;

@end

@implementation AACatalogCollectionViewController

static NSInteger animeInRequest = 30;
static NSInteger pageInRequest = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    self.blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    self.blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    [self.blurEffectView setFrame:self.view.frame];
    [self.view addSubview:self.blurEffectView];
    
    pageInRequest = 0;
    self.animeArray = [NSMutableArray array];
    self.loadingCell = YES;
    
    [self getAnimeCatalogFromServer];
    
    SWRevealViewController *revealController = [self revealViewController];
    
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:25/255.0 green:181/255.0 blue:254/255.0 alpha:1];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_menu"] style:UIBarButtonItemStylePlain target:revealController action:@selector(revealToggle:)];
    [self.navigationController.navigationBar.topItem setLeftBarButtonItem:revealButtonItem];
    [revealButtonItem setTintColor:[UIColor whiteColor]];
    
    UIBarButtonItem *searchButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(showSearchController)];
    [self.navigationController.navigationBar.topItem setRightBarButtonItem:searchButtonItem];
    [searchButtonItem setTintColor:[UIColor whiteColor]];
    
    self.titleButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.titleButton setTitle:@"     По рейтингу      " forState:UIControlStateNormal];
    [self.titleButton setImage:[[UIImage imageNamed:@"arrow_down_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.titleButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, -5)];
    [self.titleButton addTarget:self action:@selector(presentMenu:) forControlEvents:UIControlEventTouchUpInside];
    self.titleButton.titleLabel.font =  [UIFont fontWithName:@"Copperplate" size:18.0];
    self.titleButton.titleEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
    self.titleButton.imageEdgeInsets = UIEdgeInsetsMake(0, 142, 0, -5);
    [self.titleButton sizeToFit];
    self.navigationItem.titleView = self.titleButton;
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.jpg"]];
    self.collectionView.backgroundView = tempImageView;
    
    UIBlurEffect *backgroundblurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *backgroundBlurEffectView = [[UIVisualEffectView alloc] initWithEffect:backgroundblurEffect];
    backgroundBlurEffectView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    [backgroundBlurEffectView setFrame:self.collectionView.frame];
    [tempImageView addSubview:backgroundBlurEffectView];
    
    self.placeholder = [UIImage imageNamed:@"imageholder"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)showSearchController {
    UIViewController *searchVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
    [self.navigationController pushViewController:searchVC animated:YES];
}

- (void) setCALayerForImage:(AAAnimeCollectionViewCell *)cell {
    cell.backgroundColor = [UIColor whiteColor];
    cell.layer.borderWidth = 1.0f;
    cell.layer.borderColor = [UIColor grayColor].CGColor;
    cell.layer.cornerRadius = 6.0f;
}

- (void)presentMenu:(id)sender {
    NSAttributedString *(^attributedTitle)(NSString *title) = ^NSAttributedString *(NSString *title) {
        UIColor *textColor = [UIColor lightTextColor];
        
        return [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:textColor, NSFontAttributeName:[UIFont fontWithName:@"Copperplate" size:17.0f]}];
    };
    NSArray *styleItems =
    @[
      [RWDropdownMenuItem itemWithAttributedText:attributedTitle(@"По рейтингу") image:nil action:^{
          [SVProgressHUD show];
          
          self.titleButton.titleEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
          self.titleButton.imageEdgeInsets = UIEdgeInsetsMake(0, 142, 0, -5);
          [self.titleButton setTitle:@"     По рейтингу      " forState:UIControlStateNormal];
          
          self.order = @"ranked";
          [self.animeArray removeAllObjects];
          pageInRequest = 0;
          [self getAnimeCatalogFromServer];
      }],
      [RWDropdownMenuItem itemWithAttributedText:attributedTitle(@"По популярности") image:nil action:^{
          [SVProgressHUD show];
          
          self.titleButton.titleEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
          self.titleButton.imageEdgeInsets = UIEdgeInsetsMake(0, 176, 0, -5);
          [self.titleButton setTitle:@"По популярности" forState:UIControlStateNormal];
    
          self.order = @"popularity";
          [self.animeArray removeAllObjects];
          pageInRequest = 0;
          [self getAnimeCatalogFromServer];
      }],
      [RWDropdownMenuItem itemWithAttributedText:attributedTitle(@"По дате выхода") image:nil action:^{
          [SVProgressHUD show];
          
          self.titleButton.titleEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
          self.titleButton.imageEdgeInsets = UIEdgeInsetsMake(0, 170, 0, -5);
          [self.titleButton setTitle:@"По дате выхода" forState:UIControlStateNormal];
          
          self.order = @"aired_on";
          [self.animeArray removeAllObjects];
          pageInRequest = 0;
          [self getAnimeCatalogFromServer];
      }],
      ];
    
    [RWDropdownMenu presentFromViewController:self withItems:styleItems align:RWDropdownMenuCellAlignmentCenter style:0 navBarImage:nil completion:nil];
}

#pragma mark - API Methods

- (void) getAnimeCatalogFromServer {
    
    [SVProgressHUD show];
    
    [[AAServerManager shareManager] getAnimeCatalog:pageInRequest = pageInRequest + 1
                                           count:animeInRequest
                                           order:self.order
                                          status:self.status
                                       onSuccess:^(NSArray *anime) {
                                           [self.animeArray addObjectsFromArray:anime];
                                           self.addPaths = [NSMutableArray array];
                                           
                                           for (int i = (int)[self.animeArray count] - (int)[anime count]; i < [self.animeArray count]; i++) {
                                               [self.addPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                                           }
                                           
                                           self.loadingCell = NO;
                                           [self.collectionView reloadData];
                                           [SVProgressHUD dismiss];
                                           [self.blurEffectView removeFromSuperview];
                                           
                                       }
                                       onFailure:^(NSError *error, NSInteger statusCode) {
                                           [self.blurEffectView removeFromSuperview];
                                           [SVProgressHUD dismiss];
                                           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка"
                                                                                           message:@"Не удалось подключиться к серверу. Попробовать еще раз?"
                                                                                          delegate:self
                                                                                 cancelButtonTitle:@"Нет"
                                                                                 otherButtonTitles:@"Да", nil];
                                           [alert show];
                                       }];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.animeArray count];
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * const reuseIdentifier = @"Cell";
    AAAnimeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[AAAnimeCollectionViewCell alloc] init];
    }
    
    AAAnimeCatalog *anime = [self.animeArray objectAtIndex:indexPath.row];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://shikimori.org%@", anime.imageURL]]];
    __weak AAAnimeCollectionViewCell* weakCell = cell;
    
    [cell.imageView
     setImageWithURLRequest:request
     placeholderImage:self.placeholder
     success:^(NSURLRequest * request, NSHTTPURLResponse *response, UIImage *image) {
         weakCell.imageView.image = image;
         [weakCell layoutSubviews];
     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
         NSLog(@"%@", error);
     }];
    
    cell.textLabel.text = anime.russian;
    
    [self setCALayerForImage:cell];
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    int columnIphone = 2;
    int columnIpad = 5;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        CGSize size = CGSizeMake ((self.collectionView.bounds.size.width / columnIpad) - (columnIphone * 8), 240);
        return size;
    } else {
        CGSize size = CGSizeMake ((self.collectionView.bounds.size.width / columnIphone) - (columnIphone * 8), 240);
        return size;
    }
    
    return CGSizeZero;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(8, 8, 8, 8);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height - 20) {
        if (!self.loadingCell) {
            [SVProgressHUD show];
            [self getAnimeCatalogFromServer];
            self.loadingCell = YES;
        }
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"Да"]) {
        pageInRequest = 0;
        [self getAnimeCatalogFromServer];
    }
}

#pragma mark - Navigation Methods

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
    
    if ([[segue identifier] isEqualToString:@"profile"]) {
        
        AAAnimeCatalog *anime = [self.animeArray objectAtIndex:indexPath.row];
        AAAnimeProfileViewController *destination1 = [segue destinationViewController];
        destination1.animeID = anime.animeID;
    }
}

@end
