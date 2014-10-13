//
//  FriendsViewController.m
//  Ribbit
//
//  Created by Noah Teshu on 10/2/14.
//  Copyright (c) 2014 Noah Teshu. All rights reserved.
//

#import "FriendsViewController.h"
#import "EditFriendsViewController.h"
#import "GravatarUrlBuilder.h"

@interface FriendsViewController ()

@end

@implementation FriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

-(void)viewWillAppear:(BOOL)animated

{
    
    //putting the friendsRelation here makes it so it will be refreshed every time the view appears
    self.friendsRelation = [[PFUser currentUser]objectForKey:@"friendsRelation"];
    PFQuery *query = [self.friendsRelation query];
    [query orderByAscending:@"username"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, error.userInfo);
        } else {
            //friends listed are a result of the query. Returns all objects that match the key "friendsRelation"
            self.friends = objects;
            //refresh the tableView with the new information
            [self.tableView reloadData];
        }
        
    }];

    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showEditFriends"]) {
        //another example of casting. Sender has a type of id by default. this tells the FriendsViewController to treat the destination view controller as an instance of EditFriendsViewController
        EditFriendsViewController *viewController = (EditFriendsViewController* )segue.destinationViewController;
        viewController.friends = [NSMutableArray arrayWithArray:self.friends];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return self.friends.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    PFUser *user = [self.friends objectAtIndex:indexPath.row];
    
    cell.textLabel.text = user.username;
    
    //all lowercase names is because it's a C struct
    //get the main queue
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //dispatch asynchronously to that queue
    dispatch_async(queue, ^{
        //1. get email address
        //user represents user for given row
        NSString *email = [user objectForKey:@"email"];
        
        //2. create the md5 hash
        //note: md5 hashes are not secure enough to trust with sensitive data
        //this is a profile picture, so...good enough for this. Just something to be aware of.
        //get gravatar url associated with email address
        NSURL *gravatarUrl = [GravatarUrlBuilder getGravatarUrl:email];
        
        //3. request image from Gravatar
        NSData *imageData = [NSData dataWithContentsOfURL:gravatarUrl];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (imageData != nil) {
                //4. set image in cell
                cell.imageView.image = [UIImage imageWithData:imageData];
                //refresh the cell to add the image
                [cell setNeedsLayout];
            }
            
            
        });
        

    });
    
    //default image for if gravatar is unable to find image for user
    //if gravatar does find an image, it will write over this 
    cell.imageView.image = [UIImage imageNamed:@"icon_person"];
    return cell;
    
}

@end
