//
//  ABXFAQsViewController.m
//
//  Created by Stuart Hall on 21/05/2014.
//  Copyright (c) 2014 Appbot. All rights reserved.
//

#import "ABXFAQsViewController.h"

#import "ABXFaq.h"
#import "ABXFAQViewController.h"
#import "ABXFeedbackViewController.h"
#import "ABXFAQTableViewCell.h"

@interface ABXFAQsViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) NSArray *faqs;
@property (nonatomic, strong) NSArray *filteredFaqs;

@property (nonatomic, strong) UISearchBar *searchBar;

@end

@implementation ABXFAQsViewController

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource= nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Title
    self.title = NSLocalizedString(@"FAQs", nil);
    
    // Setup our UI components
    [self setupFaqUI];
    
    // Fetch
    if (![ABXApiClient isInternetReachable]) {
        [self.activityView stopAnimating];
        [self showError:NSLocalizedString(@"There is no internet connection.\r\n\r\nPlease connect to continue.", nil)];
    }
    else {
        [self fetchFAQs];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Show the keyboard again if it was before
    if (self.searchBar.text.length > 0) {
        [self.searchBar becomeFirstResponder];
        [self searchBar:self.searchBar textDidChange:self.searchBar.text];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI

- (void)setupFaqUI
{
    // Search bar
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44)];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = NSLocalizedString(@"Search...", nil);
    self.tableView.tableHeaderView = self.searchBar;
    
    // Nav buttons
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:NSLocalizedString(@"Contact", nil)
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(onContact)];
}

#pragma mark - Fetching

- (void)fetchFAQs
{
    self.tableView.hidden = YES;
    [self.activityView startAnimating];
    [ABXFaq fetch:^(NSArray *faqs, ABXResponseCode responseCode, NSInteger httpCode, NSError *error) {
        [self.activityView stopAnimating];
        if (responseCode == ABXResponseCodeSuccess) {
            self.faqs = faqs;
            self.filteredFaqs = faqs;
            [self.tableView reloadData];
            
            if (faqs.count == 0) {
                [self showError:NSLocalizedString(@"No FAQs found.", nil)];
            }
            else {
                self.tableView.hidden = NO;
            }
        }
        else {
            [self showError:NSLocalizedString(@"Unable to fetch FAQs.\r\nplease try again later", nil)];
        }
    }];
}

#pragma mark - Buttons

- (void)onContact
{
    [ABXFeedbackViewController showFromController:self
                                      placeholder:NSLocalizedString(@"How can we help?", nil)];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.filteredFaqs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FAQCell";
    
    ABXFAQTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[ABXFAQTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.row < self.filteredFaqs.count) {
        [cell setFAQ:[self.filteredFaqs objectAtIndex:indexPath.row]];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.filteredFaqs.count) {
        return [ABXFAQTableViewCell heightForFAQ:[self.filteredFaqs objectAtIndex:indexPath.row]
                                       withWidth:CGRectGetWidth(self.tableView.bounds)];
    }
    
    return 0;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row < self.filteredFaqs.count) {
        // Fix weird keyboard transition lag in iOS 7
        if ([self.searchBar isFirstResponder]) {
            [self.searchBar resignFirstResponder];
        }
        
        // Show the details
        ABXFAQViewController* controller = [[ABXFAQViewController alloc] init];
        controller.faq = self.faqs[indexPath.row];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.question contains[cd] %@ OR SELF.answer contains[cd] %@", searchText, searchText];
        self.filteredFaqs = [self.faqs filteredArrayUsingPredicate:predicate];
        
        if (self.filteredFaqs.count > 0) {
            self.errorLabel.hidden = YES;
        }
        else {
            [self showError:NSLocalizedString(@"No matches found", nil)];
        }
    }
    else {
        self.filteredFaqs = self.faqs;
    }
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    searchBar.text = @"";
    
    self.errorLabel.hidden = YES;
    self.filteredFaqs = self.faqs;
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

@end
