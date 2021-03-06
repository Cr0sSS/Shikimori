//
//  AAVideoViewController.m
//  Shikimori
//
//  Created by Admin on 30.03.16.
//  Copyright © 2016 Arsen Avanesyan. All rights reserved.
//

#import "AAAnimeVideoViewController.h"
#import "TFHpple.h"
#import "AAAnimeVideo.h"
#import "SVProgressHUD.h"

@interface AAAnimeVideoViewController ()

@property (strong, nonatomic) NSString *sourceURL;
@property (strong, nonatomic) NSMutableArray *videoOptions;
@property (strong, nonatomic) NSMutableArray *videoResourceURLs;
@property (strong, nonatomic) AAAnimeVideo *videoURL;
@property (strong, nonatomic) WKWebView *webView;
@property (strong, nonatomic) UIView *videoView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@implementation AAAnimeVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [UIView new];
    
    if (IS_IPAD) {
        self.tableView.rowHeight = 56;
    } else {
        self.tableView.rowHeight = 34;
    }
    
    CGFloat navBarHeight = self.navigationController.navigationBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y;
    CGFloat webViewHeight = 320 - navBarHeight;
    
    self.videoOptions = [NSMutableArray array];
    self.videoResourceURLs = [NSMutableArray array];
    self.sourceURL = [NSString stringWithFormat:@"https://play.shikimori.org/animes/%@/video_online", self.animeID];
    
    self.videoView = [[UIView alloc] initWithFrame:CGRectMake(0, navBarHeight, self.view.bounds.size.width, webViewHeight)];
    
    self.videoView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.videoView];

    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width - 8, webViewHeight)];
    [self.videoView addSubview:self.webView];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:self.webView.frame];
    self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    self.activityIndicator.color = [UIColor colorWithRed:25/255.0 green:181/255.0 blue:254/255.0 alpha:1];
    
    [self.webView addSubview:self.activityIndicator];
    
    self.webView.scrollView.scrollEnabled = NO;
    self.webView.scrollView.bounces = NO;
    self.webView.navigationDelegate = self;
    
    [self parseVideoEpisode];
    [self parseVideoURL];
}

#pragma mark - Parse Methods

- (void) parseVideoEpisode {
    [SVProgressHUD show];
    
    UIView *preloadView = [[UIView alloc] init];
    preloadView.backgroundColor = [UIColor whiteColor];
    preloadView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    [preloadView setFrame:self.view.frame];
    [self.view addSubview:preloadView];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        [self.activityIndicator startAnimating];
        
        self.sourceURL = [NSString stringWithFormat:@"https://play.shikimori.org/animes/%@/video_online", self.animeID];
        
        NSData *sourceHTMLData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.sourceURL]];
        
        TFHpple *parser = [TFHpple hppleWithHTMLData:sourceHTMLData];
        
        NSString *videoURLXpathQueryString1 = @"//div[@class='c-episodes']/div[@class='video-variant']/a";
        NSString *videoURLXpathQueryString2 = @"//div[@class='c-episodes']/div/div[@class='video-variant']/a";
        
        
        NSArray *videoURLNodes1 = [parser searchWithXPathQuery:videoURLXpathQueryString1];
        NSArray *videoURLNodes2 = [parser searchWithXPathQuery:videoURLXpathQueryString2];
        
        for (TFHppleElement *element in videoURLNodes1) {
            AAAnimeVideo *video = [[AAAnimeVideo alloc] init];
            [self.videoOptions addObject:video];
            video.videoOption = [element objectForKey:@"href"];
        }
        
        for (TFHppleElement *element in videoURLNodes2) {
            AAAnimeVideo *video = [[AAAnimeVideo alloc] init];
            [self.videoOptions addObject:video];
            video.videoOption = [element objectForKey:@"href"];
        }
        
        if ([self.videoOptions count] == 0) {
            
            self.sourceURL = [NSString stringWithFormat:@"https://play.shikimori.org/animes/z%@/video_online", self.animeID];
            
            NSData *sourceHTMLData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.sourceURL]];
            
            TFHpple *parser = [TFHpple hppleWithHTMLData:sourceHTMLData];
            
            NSString *videoURLXpathQueryString1 = @"//div[@class='c-episodes']/div[@class='video-variant']/a";
            NSString *videoURLXpathQueryString2 = @"//div[@class='c-episodes']/div/div[@class='video-variant']/a";
            
            
            NSArray *videoURLNodes1 = [parser searchWithXPathQuery:videoURLXpathQueryString1];
            NSArray *videoURLNodes2 = [parser searchWithXPathQuery:videoURLXpathQueryString2];
            
            for (TFHppleElement *element in videoURLNodes1) {
                AAAnimeVideo *video = [[AAAnimeVideo alloc] init];
                [self.videoOptions addObject:video];
                video.videoOption = [element objectForKey:@"href"];
            }
            
            for (TFHppleElement *element in videoURLNodes2) {
                AAAnimeVideo *video= [[AAAnimeVideo alloc] init];
                [self.videoOptions addObject:video];
                video.videoOption = [element objectForKey:@"href"];
            }
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [SVProgressHUD dismiss];
            [preloadView removeFromSuperview];
        });
    });
}


- (void) parseVideoURL {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        NSData *sourceHTMLData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https:%@", self.sourceURL]]];
        
        TFHpple *parser = [TFHpple hppleWithHTMLData:sourceHTMLData];
        
        NSString *videoResourceURLXpathQueryString = @"//iframe";
        
        NSArray *videoResourceURLNodes = [parser searchWithXPathQuery:videoResourceURLXpathQueryString];
        
        for (TFHppleElement *element in videoResourceURLNodes) {
            self.videoURL = [[AAAnimeVideo alloc] init];
            [self.videoResourceURLs addObject:self.videoURL];
            self.videoURL.videoResourceURL = [element objectForKey:@"src"];
            
            CGFloat width = self.webView.frame.size.width ;
            CGFloat height = self.webView.frame.size.height ;
            NSString* htmlString = [NSString stringWithFormat:@"<iframe src=\"https:%@\" width=\"%f\" height=\"%f\" frameborder=\"0\"></iframe>", self.videoURL.videoResourceURL , width, height];
            [self.webView loadHTMLString:htmlString baseURL:nil];
        }
        
        
        if ([videoResourceURLNodes count] == 0) {
            
            NSData *sourceHTMLData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.sourceURL]];
            
            TFHpple *parser = [TFHpple hppleWithHTMLData:sourceHTMLData];
            
            NSString *videoResourceURLXpathQueryString = @"//embed";
            
            videoResourceURLNodes = [parser searchWithXPathQuery:videoResourceURLXpathQueryString];
            
            for (TFHppleElement *element in videoResourceURLNodes) {
                self.videoURL = [[AAAnimeVideo alloc] init];
                [self.videoResourceURLs addObject:self.videoURL];
                self.videoURL.videoResourceURL = [element objectForKey:@"src"];
                CGFloat width = self.webView.frame.size.width ;
                CGFloat height = self.webView.frame.size.height ;
                NSString* htmlString = [NSString stringWithFormat:@"<iframe src=\"https:%@\" width=\"%f\" height=\"%f\" frameborder=\"0\"></iframe>", self.videoURL.videoResourceURL , width, height];
                [self.webView loadHTMLString:htmlString baseURL:nil];
            }
        }
        
        if ([videoResourceURLNodes count] == 0) {
            
            NSData *sourceHTMLData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.sourceURL]];
            
            TFHpple *parser = [TFHpple hppleWithHTMLData:sourceHTMLData];
            
            NSString *videoResourceURLXpathQueryString = @"//iframe";
            
            NSArray *videoResourceURLNodes = [parser searchWithXPathQuery:videoResourceURLXpathQueryString];
            
            for (TFHppleElement *element in videoResourceURLNodes) {
                self.videoURL = [[AAAnimeVideo alloc] init];
                [self.videoResourceURLs addObject:self.videoURL];
                self.videoURL.videoResourceURL = [element objectForKey:@"src"];
                
                CGFloat width = self.webView.frame.size.width;
                CGFloat height = self.webView.frame.size.height;
                NSString* htmlString = [NSString stringWithFormat:@"<iframe src=\"https:%@\" width=\"%f\" height=\"%f\" frameborder=\"0\"></iframe>", self.videoURL.videoResourceURL , width, height];
                [self.webView loadHTMLString:htmlString baseURL:nil];
            }
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [self.activityIndicator stopAnimating];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    [self.activityIndicator stopAnimating];
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    NSString *javascript = @"var meta = document.createElement('meta');meta.setAttribute('name', 'viewport');meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no');document.getElementsByTagName('head')[0].appendChild(meta);";
    
    [webView evaluateJavaScript:javascript completionHandler:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.videoOptions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const reuseIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] init];
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIFont *myFont =  [UIFont fontWithName:@"Copperplate" size:18.0];
        cell.textLabel.font  = myFont;
    } else {
        UIFont *myFont =  [UIFont fontWithName:@"Copperplate" size:14.0];
        cell.textLabel.font  = myFont;
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%ld серия", indexPath.row + 1];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Эпизоды";
}

#pragma mark UITableViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.activityIndicator startAnimating];
    AAAnimeVideo *video = [self.videoOptions objectAtIndex:indexPath.row];
    self.sourceURL = video.videoOption;
    [self.videoResourceURLs removeAllObjects];
    [self parseVideoURL];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *headerLabel = [[UILabel alloc] init];
    headerLabel.frame = CGRectMake(0, 0, self.view.bounds.size.width, 24);
    headerLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
    headerLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    headerLabel.backgroundColor = [UIColor colorWithRed:247/255.0f green:247/255.0f blue:247/255.0f alpha:1.0f];
    
    if (IS_IPAD) {
        headerLabel.font = [UIFont fontWithName:@"Copperplate" size:22.0];
    } else {
        headerLabel.font = [UIFont fontWithName:@"Copperplate" size:16.0];
    }
    
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:headerLabel];
    
    return headerView;
}

@end
