//
//  InboxViewController.h
//  Ribbit
//
//  Created by Noah Teshu on 10/1/14.
//  Copyright (c) 2014 Noah Teshu. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Parse/Parse.h>
#import <MediaPlayer/MediaPlayer.h>

@interface InboxViewController : UITableViewController

@property (strong, nonatomic) NSArray *messages;
@property (strong, nonatomic) PFObject *selectedMessage;
@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

- (IBAction)logout:(id)sender;

@end
