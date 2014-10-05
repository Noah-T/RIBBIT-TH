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

- (IBAction)cancel:(id)sender {
    [self reset];
    [self.tabBarController setSelectedIndex:0];
}

- (IBAction)send:(id)sender {
    
    //length check also covers nil:
    /////length 0 wouldn't be nil, but would be a length of 0
    
    //if there is an image with a value of nil and no video, show an alert, and then go back to the camera
    if (self.image == nil && self.videoFilePath.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Try again!" message:@"Please capture or select a photo or video to share!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [self presentViewController:self.imagePicker animated:NO completion:nil];
    } else {
        [self uploadMessage];
        
        [self.tabBarController setSelectedIndex:0];
    }
}

#pragma mark - Helper Methods

- (void)reset {
    self.image = nil;
    self.videoFilePath = nil;
    [self.recipients removeAllObjects];
}

- (UIImage *)resizeImage:(UIImage *)image toWidth:(float)width andHeight:(float)height
{
    //this works with the passed in parameters: set a size equal to the width and height passed in
    CGSize newSize = CGSizeMake(width, height);
    //something new I learned about CGRect:
    //it basically makes two points: 1. x and y coordinates for upper left 2. x and y coordinates for bottom right. It's smart enough to fill in the rest from here
    
    //convert the passed in size to a rectangle
    CGRect newRectangle = CGRectMake(0, 0, width, height);
    
    //create an image context based on the passed in size
    UIGraphicsBeginImageContext(newSize);
    
    //take the passed in image and draw it onto a rectangle of the passed in size
    //(resize image to passed in dimensions)
    [image drawInRect:newRectangle];
    
    //get the image from the current image context
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //this must be used anytime beginImagecontext is used
    UIGraphicsEndImageContext();
    
    //return the final value
    return resizedImage;
}

- (void)uploadMessage
{
    NSData *fileData;
    NSString *fileName;
    NSString *fileType;
    if (self.image != nil) {
        
        //if it's an image
        UIImage *newImage = [self resizeImage:self.image toWidth:320.0f andHeight:480.0f];
        
        //pass the resized image to fileData
        fileData = UIImagePNGRepresentation(newImage);
        fileName = @"image.png";
        fileType = @"image";
    } else {
        //if it's a video
        fileData = [NSData dataWithContentsOfFile:self.videoFilePath];
        fileName = @"movie.mov";
        fileType = @"video";
    }
    
    PFFile *file = [PFFile fileWithName:fileName data:fileData];
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        


        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"An error occurred!" message:@"Please try sending your message again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];

        } else {
            //note Messages with a capital "M". Start with captal letter, use camelCase
            PFObject *message = [PFObject objectWithClassName:@"Messages"];
            [message setObject:file forKey:@"file"];
            [message setObject:fileType forKey:@"fileType"];
            [message setObject:self.recipients forKey:@"recipientIds"];
            [message setObject:[[PFUser currentUser]objectId] forKey:@"senderId"];
            [message setObject:[[PFUser currentUser]username] forKey:@"senderName"];
            [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"An error occurred!" message:@"Please try sending your message again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView show];
                } else {
                    //Everything was successful!
                    //this is a safe place to reset, otherwise it could interfere with asynchronous syncing
                    //it will also preserve image/video and receipients if the failure is on the backend
                    sleep(4);
                    MBProgressHUD *hud = [[MBProgressHUD alloc]initWithView:self.view];
                   hud.mode = MBProgressHUDModeAnnularDeterminate;
                    hud.labelText = @"Message Sent";
                    NSLog(@"success");
                    [self.view addSubview:hud];

                    [hud show:YES];
                    sleep(2);
                    [hud show:NO];

                                        [self reset];
                    
                }
                
            }];
        }
    }];
    
}


@end
