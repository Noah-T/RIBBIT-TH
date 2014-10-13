//
//  InboxViewController.m
//  Ribbit
//
//  Created by Noah Teshu on 10/1/14.
//  Copyright (c) 2014 Noah Teshu. All rights reserved.
//

#import "InboxViewController.h"
#import "ImageViewController.h"
#import "MSCellAccessory.h"


@interface InboxViewController ()

@end

@implementation InboxViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.moviePlayer = [[MPMoviePlayerController alloc] init];
    
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    
    //call retrieveMessages when refresh control is pulled
    [self.refreshControl addTarget:self action:@selector(retrieveMessages) forControlEvents:UIControlEventValueChanged];
    
    
    }


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //all messages have the messages class
    
    self.navigationController.navigationBarHidden = NO;
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        NSLog(@"Current user: %@", currentUser.username);
        [self retrieveMessages];

    }
    else {
        [self performSegueWithIdentifier:@"doSegue" sender:self];
    }

    
    
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    return self.messages.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *message = [self.messages objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.textLabel.text = [message objectForKey:@"senderName"];
    
    UIColor *disclosureColor = [UIColor colorWithRed:0.553 green:0.439 blue:0.718 alpha:1.0];
    cell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_DISCLOSURE_INDICATOR color:disclosureColor];
    
    
    NSString *fileType = [message objectForKey:@"fileType"];
    
    if ([fileType isEqualToString:@"image"]) {
        cell.imageView.image = [UIImage imageNamed:@"icon_image"];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"icon_video"];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedMessage = [self.messages objectAtIndex:indexPath.row];
    
    NSString *fileType = [self.selectedMessage objectForKey:@"fileType"];
    
    if ([fileType isEqualToString:@"image"]) {
        [self performSegueWithIdentifier:@"showImage" sender:self];
    } else {
        
        //show video here
        PFFile *videoFile = [self.selectedMessage objectForKey:@"file"];
        NSURL *fileUrl = [NSURL URLWithString:videoFile.url];
        self.moviePlayer.contentURL = fileUrl;
        
        //gets movie ready, probably some caching
        [self.moviePlayer prepareToPlay];
        [self.moviePlayer requestThumbnailImagesAtTimes:@[@0] timeOption:MPMovieTimeOptionNearestKeyFrame];
        
        //movie player is added as a subview, not as a modal view controller
        [self.view addSubview:self.moviePlayer.view];
        
        //setFullScreen must be called after it's added to view
        [self.moviePlayer setFullscreen:YES animated:YES];
    }
    
    NSMutableArray *recipientIds = [NSMutableArray arrayWithArray:[self.selectedMessage objectForKey:@"recipientIds"]];
    NSLog(@"Recipients: %lu", (unsigned long)recipientIds.count);
    
    if(recipientIds.count == 1){
        //delete it

        [self.selectedMessage deleteInBackground];
        [self.tableView reloadData];
    } else {

        //remove recipient from recipient list (locally)
        [recipientIds removeObject:[[PFUser currentUser]objectId]];

        //take the locally updated recipient list and save it to the object on Parse
        [self.selectedMessage setObject:recipientIds forKey:@"recipientIds"];
        [self.selectedMessage saveInBackground];
    }
    
}





- (IBAction)logout:(id)sender {
    [PFUser logOut];
    [self performSegueWithIdentifier:@"doSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"doSegue"]) {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
    } else if ([segue.identifier isEqualToString:@"showImage"]){
        //hide the bottom bar from the tab bar controller
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        ImageViewController *imageViewController = (ImageViewController *)segue.destinationViewController;
        imageViewController.message = self.selectedMessage;
    }
}


#pragma mark - Helper methods
- (void)retrieveMessages
{
    //create a query class to search through all messages
    PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
    //find messages where the current user id is included in the recipient field
    [query whereKey:@"recipientIds" equalTo:[[PFUser currentUser]objectId]];
    
    //sort so that the most recent messages are at the top
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, error.userInfo );
        } else {
            //returned values from the query (objects) are stored in the local property self.messages
            self.messages = objects;
            
            //reflect this change in the table
            [self.tableView reloadData];
            NSLog(@"Retrieved %lu messages", (unsigned long)self.messages.count);
        }
        //remember, this is nested in a completion block for the query to parse
        //if it's completed and the control is still refreshing, manually stop the process 
        if ([self.refreshControl isRefreshing]) {
            [self.refreshControl endRefreshing];
        }
    }];
}

@end
