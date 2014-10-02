//
//  EditFriendsViewController.h
//  Ribbit
//
//  Created by Noah Teshu on 10/2/14.
//  Copyright (c) 2014 Noah Teshu. All rights reserved.
//

#import <UIKit/UIKit.h>
//importing to the header will automatically import to the class implementation file also. Good to know.
#import <Parse/Parse.h>
@interface EditFriendsViewController : UITableViewController

@property (strong, nonatomic) NSArray *allUsers;
@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) NSMutableArray *friends;

-(BOOL)isFriend:(PFUser *)user;

@end
