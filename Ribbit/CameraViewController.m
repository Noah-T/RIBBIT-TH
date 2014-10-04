//
//  CameraViewController.m
//  Ribbit
//
//  Created by Noah Teshu on 10/2/14.
//  Copyright (c) 2014 Noah Teshu. All rights reserved.
//

#import "CameraViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>


@interface CameraViewController ()

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.friendsRelation = [[PFUser currentUser]objectForKey:@"friendsRelation"];
    self.recipients = [NSMutableArray array];
    
    
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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
    
    if (self.image == nil && self.videoFilePath.length == 0) {
        self.imagePicker = [[UIImagePickerController alloc]init];
        self.imagePicker.delegate = self;
        self.imagePicker.allowsEditing = NO;
        
        //max duration is set in seconds
        self.imagePicker.videoMaximumDuration = 10;
        
        self.imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        } else {
            //all availabe photos on the device, including other albums, like Instagram
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        
        self.imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:self.imagePicker.sourceType];
        
        
        
        [self presentViewController:self.imagePicker animated:NO completion:nil];

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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // Configure the cell...
    PFUser *user = [self.friends objectAtIndex:indexPath.row];
    
    cell.textLabel.text = user.username;
    
    if ([self.recipients containsObject:user.objectId]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //prevents selected row from staying highlighted after a tap
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    //PFUser comes from the array self.friends
    //self.friends populates the tableView
    //this particular instance is set to whichever user was tapped in the tableView
    //the user is stored by their object ID. this is less data than storing the whole user object
    PFUser *user = [self.friends objectAtIndex:indexPath.row];
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.recipients addObject:user.objectId];
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.recipients removeObject:user.objectId];
    }
}


#pragma mark - Image Picker Controller Delegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:NO completion:nil];
    
    [self.tabBarController setSelectedIndex:0];
    
    NSLog(@"this happened");
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //store the type of media returned in a string
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    //if the media type is an image
    //casting kUTTypeImage as an NSString
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        
        //set the original image (unedited) to the class image property
        self.image = [info objectForKey:UIImagePickerControllerOriginalImage];\
        //if picture came from a camera (and not selected from a photo album, save it
        if (self.imagePicker.sourceType ==UIImagePickerControllerSourceTypeCamera) {
            UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil);
        }
        
    } else {
        //a video was taken/selected
        self.videoFilePath = (NSString *)[[info objectForKey:UIImagePickerControllerMediaURL]path];
        
        //if it was taken with a camera, save the video
        if (self.imagePicker.sourceType ==UIImagePickerControllerSourceTypeCamera) {
            
            //check for file compatability
            //save the video locally
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(self.videoFilePath)) {
                UISaveVideoAtPathToSavedPhotosAlbum(self.videoFilePath, nil, nil, nil);
            }
            
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
}






#pragma mark - IBActions

//- (IBAction)cancel:(id)sender {
//    self.image = nil;
//    self.videoFilePath = nil;
//    [self.recipients removeAllObjects];
//    [self.tabBarController setSelectedIndex:0];
//}

//- (IBAction)send:(id)sender {
//    NSLog(@"send, yo");
//}
- (IBAction)cancel:(id)sender {
}

- (IBAction)send:(id)sender {
}
@end
