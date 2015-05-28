//
//  ViewController.m
//  CreationLayoutDemo
//
//  Created by Kevin Li on 2015.05.20
//  Copyright (c) 2015 Kevin Li. All rights reserved.
//

#import "ViewController.h"
#import "CreationLayout.h"

@interface ViewController () <UIGestureRecognizerDelegate>

@end

static NSString *cellId = @"cellId";
static NSString *cellId2 = @"cellId2";
static NSString *cellIdCloths = @"clothCell";



@implementation ViewController{
    NSMutableDictionary *thumbnailCache;
    BOOL showingSettings;
    UIView *settingsView;
    
    UILabel *radiusLabel;
    UISlider *radiusSlider;
    UILabel *angularSpacingLabel;
    UISlider *angularSpacingSlider;
    UILabel *xOffsetLabel;
    UISlider *xOffsetSlider;
    UISegmentedControl *exampleSwitch;
    CreationLayout *dialLayout;
    UIPanGestureRecognizer *pan;
    
    int type;
    
    UICollectionViewCell * imageCell;
    CAShapeLayer *circleShapeLayer;
    CGRect dragRect;
    CAShapeLayer *maskLayer;
    CABasicAnimation *maskAnimation;
    CALayer *snopShotLayer;
}

@synthesize collectionView, items, editBtn;
- (void)viewDidLoad
{
    [super viewDidLoad];
    type = 0;
    showingSettings = NO;
    
    [collectionView registerNib:[UINib nibWithNibName:@"dialCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:cellId];
    [collectionView registerNib:[UINib nibWithNibName:@"dialCell2" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:cellId2];
    [collectionView registerNib:[UINib nibWithNibName:@"Cloths" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:cellIdCloths];

    
    
    UIPanGestureRecognizer* pinchRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    pan = pinchRecognizer;
    [self.collectionView addGestureRecognizer:pinchRecognizer];

//    self.collectionView.panGestureRecognizer.delegate = self;
    pan.delegate = self;
    
    
    NSError *error;
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"materials" ofType:@"json"];
    NSString *jsonString = [[NSString alloc] initWithContentsOfFile:jsonPath encoding:NSUTF8StringEncoding error:NULL];
    items = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    
    settingsView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-44)];
    [settingsView setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.6]];
    [self.view addSubview:settingsView];
    [self buildSettings];
    
    
    CGFloat radius = radiusSlider.value * 1000;
    CGFloat angularSpacing = angularSpacingSlider.value * 90;
    CGFloat xOffset = xOffsetSlider.value * 320;
    CGFloat cell_width = 70;
    CGFloat cell_height = 70;
    [radiusLabel setText:[NSString stringWithFormat:@"Radius: %i", (int)radius]];
    [angularSpacingLabel setText:[NSString stringWithFormat:@"Angular spacing: %i", (int)angularSpacing]];
    [xOffsetLabel setText:[NSString stringWithFormat:@"X offset: %i", (int)xOffset]];
    
    
    
    dialLayout = [[CreationLayout alloc] initWithRadius:radius andAngularSpacing:angularSpacing andCellSize:CGSizeMake(cell_width, cell_height) andAlignment:WHEELALIGNMENTCENTER andItemHeight:cell_height andXOffset:xOffset];
    dialLayout.imageSize = CGSizeMake(500, 500);
    
    [collectionView setCollectionViewLayout:dialLayout];

    [editBtn setTarget:self];
    [editBtn setAction:@selector(toggleSettingsView)];
    
    [self switchExample];
    
    
    
}


-(void)buildSettings{
    NSArray *viewArr = [[NSBundle mainBundle] loadNibNamed:@"iphone_settings_view" owner:self options:nil];
    UIView *innerView = [viewArr objectAtIndex:0];
    CGRect frame = innerView.frame;
    frame.origin.y = (self.view.frame.size.height/2 - frame.size.height/2)/2;
    innerView.frame = frame;
    [settingsView addSubview:innerView];
    
    radiusLabel = (UILabel*)[innerView viewWithTag:100];
    radiusSlider = (UISlider*)[innerView viewWithTag:200];
    [radiusSlider addTarget:self action:@selector(updateDialSettings) forControlEvents:UIControlEventValueChanged];
    
    angularSpacingLabel = (UILabel*)[innerView viewWithTag:101];
    angularSpacingSlider = (UISlider*)[innerView viewWithTag:201];
    [angularSpacingSlider addTarget:self action:@selector(updateDialSettings) forControlEvents:UIControlEventValueChanged];
    
    xOffsetLabel = (UILabel*)[innerView viewWithTag:102];
    xOffsetSlider = (UISlider*)[innerView viewWithTag:202];
    [xOffsetSlider addTarget:self action:@selector(updateDialSettings) forControlEvents:UIControlEventValueChanged];
    
    exampleSwitch = (UISegmentedControl*)[innerView viewWithTag:203];
    [exampleSwitch addTarget:self action:@selector(switchExample) forControlEvents:UIControlEventValueChanged];
}

-(void)switchExample{
    type = (int)exampleSwitch.selectedSegmentIndex;
    CGFloat radius = 0 ,angularSpacing  = 0, xOffset = 0;
    
    if(type == 0){
        [dialLayout setCellSize:CGSizeMake(60, 60)];
        [dialLayout setWheelType:WHEELALIGNMENTLEFT];
        
        radius = 98;
        angularSpacing = 48;
        xOffset = 258;
    }else if(type == 1){
        [dialLayout setCellSize:CGSizeMake(260, 50)];
        [dialLayout setWheelType:WHEELALIGNMENTCENTER];
        
        radius = 320;
        angularSpacing = 5;
        xOffset = 124;
    }
    
    [radiusLabel setText:[NSString stringWithFormat:@"Radius: %i", (int)radius]];
    radiusSlider.value = radius/1000;
    [dialLayout setDialRadius:radius];
    
    [angularSpacingLabel setText:[NSString stringWithFormat:@"Angular spacing: %i", (int)angularSpacing]];
    angularSpacingSlider.value = angularSpacing / 90;
    [dialLayout setAngularSpacing:angularSpacing];
    
    [xOffsetLabel setText:[NSString stringWithFormat:@"X offset: %i", (int)xOffset]];
    xOffsetSlider.value = xOffset/320;
    [dialLayout setXOffset:xOffset];
    
    
    [collectionView reloadData];

}

-(void)updateDialSettings{
    CGFloat radius = radiusSlider.value * 1000;
    CGFloat angularSpacing = angularSpacingSlider.value * 90;
    CGFloat xOffset = xOffsetSlider.value * 320;
    
    [radiusLabel setText:[NSString stringWithFormat:@"Radius: %i", (int)radius]];
    [dialLayout setDialRadius:radius];
    
    [angularSpacingLabel setText:[NSString stringWithFormat:@"Angular spacing: %i", (int)angularSpacing]];
    [dialLayout setAngularSpacing:angularSpacing];
    
    [xOffsetLabel setText:[NSString stringWithFormat:@"X offset: %i", (int)xOffset]];
    [dialLayout setXOffset:xOffset];
    
    [dialLayout invalidateLayout];
    //[collectionView reloadData];
    NSLog(@"updateDialSettings");
}

-(void)toggleSettingsView{
    CGRect frame = settingsView.frame;
    if(showingSettings){
        editBtn.title = @"Edit";
        frame.origin.y = self.view.frame.size.height;
    }else{
        editBtn.title = @"Close";
        frame.origin.y = 44;
    }
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        settingsView.frame = frame;
    } completion:^(BOOL finished) {
        
    }];
    
    showingSettings = !showingSettings;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    } else if (section == 1){
        return self.items.count;
    } else {
        NSAssert(NO, @"shoule only have 2 secitons");
        return 0;
    }
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 2;
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (UICollectionViewCell *)getCircleCellWithIndex:(NSIndexPath *)indexPath cv:(UICollectionView *)cv {
    UICollectionViewCell *cell;
    if(type == 0){
        cell = [cv dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    }else{
        cell = [cv dequeueReusableCellWithReuseIdentifier:cellId2 forIndexPath:indexPath];
    }
    
    NSDictionary *item = [self.items objectAtIndex:indexPath.item];
    
    NSString *playerName = [item valueForKey:@"name"];
    UILabel *nameLabel = (UILabel*)[cell viewWithTag:101];
    [nameLabel setText:playerName];
    
    
    NSString *hexColor = [item valueForKey:@"cloth-color"];
    
    
    if(type == 0){
        UIView *borderView = [cell viewWithTag:102];
        
        borderView.layer.borderWidth = 1;
        borderView.layer.borderColor = [self colorFromHex:hexColor].CGColor;
        
        NSString *imgURL = [item valueForKey:@"picture"];
        UIImageView *imgView = (UIImageView*)[cell viewWithTag:100];
        UILabel *label = (UILabel*)[cell viewWithTag:555];
        label.text = @(indexPath.item).stringValue;
        [imgView setImage:nil];
        __block UIImage *imageProduct = [thumbnailCache objectForKey:imgURL];
        if(imageProduct){
            imgView.image = imageProduct;
        }
        else{
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(queue, ^{
                UIImage *image = [UIImage imageNamed:imgURL];
                dispatch_async(dispatch_get_main_queue(), ^{
                    imgView.image = image;
                    [thumbnailCache setValue:image forKey:imgURL];
                });
            });
        }
        
    }else{
        nameLabel.textColor = [self colorFromHex:hexColor];
    }
    return cell;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell;
    
    if (indexPath.section == 0) {
        cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"clothCell" forIndexPath:indexPath];
        UIImageView *clothImageView = (UIImageView*)[cell viewWithTag:11111];
        clothImageView.image = [UIImage imageNamed:@"3.png"];
        cell.userInteractionEnabled = NO;
        imageCell = cell;
        
    } else if (indexPath.section == 1){
        cell = [self getCircleCellWithIndex:indexPath cv:cv];

    }
    
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"didEndDisplayingCell:%i", (int)indexPath.item);
}


#pragma mark misc

- (unsigned int)intFromHexString:(NSString *)hexStr
{
    unsigned int hexInt = 0;
    // Create scanner
    NSScanner *scanner = [NSScanner scannerWithString:hexStr];
    // Tell scanner to skip the # character
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
    // Scan hex value
    [scanner scanHexInt:&hexInt];
    return hexInt;
}

-(UIColor*)colorFromHex:(NSString*)hexString{
    unsigned int hexint = [self intFromHexString:hexString];
    
    // Create color object, specifying alpha as well
    UIColor *color =
    [UIColor colorWithRed:((CGFloat) ((hexint & 0xFF0000) >> 16))/255
                    green:((CGFloat) ((hexint & 0xFF00) >> 8))/255
                     blue:((CGFloat) (hexint & 0xFF))/255
                    alpha:1];
    
    return color;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark gesture

- (void)handlePinchGesture:(UIPanGestureRecognizer *)sender
{
    CreationLayout* pinchLayout = (CreationLayout*)self.collectionView.collectionViewLayout;
    
    dragRect = CGRectMake(self.view.frame.size.width/2 - 50, self.view.frame.size.height/2 - 50, 100, 100);

    
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        CGPoint initialPinchPoint = [sender locationInView:self.collectionView];
        NSIndexPath* pinchedCellPath = [self.collectionView indexPathForItemAtPoint:initialPinchPoint];
        
       
        
        pinchLayout.pinchedCellPath = pinchedCellPath;
        
        circleShapeLayer = [CAShapeLayer layer];
        [self.view.layer addSublayer:circleShapeLayer];
        circleShapeLayer.fillColor = [UIColor colorWithWhite:1.0 alpha:0.3].CGColor;
        circleShapeLayer.path = [UIBezierPath bezierPathWithOvalInRect:dragRect].CGPath;
        
        
    }
    
    else if (sender.state == UIGestureRecognizerStateChanged)
    {
        pinchLayout.pinchedCellScale = 1.3;
        pinchLayout.pinchedCellCenter = [sender locationInView:self.collectionView];
        
        CGPoint testPinchPoint = [sender locationInView:self.view];

        
        if (CGRectContainsPoint(dragRect,testPinchPoint)) {
            
            circleShapeLayer.fillColor = [UIColor colorWithWhite:1.0 alpha:0.6].CGColor;
            circleShapeLayer.path = [UIBezierPath bezierPathWithOvalInRect:dragRect].CGPath;
        } else {
            circleShapeLayer.fillColor = [UIColor colorWithWhite:1.0 alpha:0.3].CGColor;
            circleShapeLayer.path = [UIBezierPath bezierPathWithOvalInRect:dragRect].CGPath;
        }
        

    }
    
    else
    {
        [self.collectionView performBatchUpdates:^{
            pinchLayout.pinchedCellPath = nil;
            pinchLayout.pinchedCellScale = 1.0;
            
            [circleShapeLayer removeFromSuperlayer];

            
        } completion:^(BOOL finish){
            
            CGPoint testPinchPoint = [sender locationInView:self.view];


            if (CGRectContainsPoint(dragRect, testPinchPoint)) {
                UIImageView *imageView = (UIImageView*)[imageCell viewWithTag:11111];

                maskLayer = [CAShapeLayer layer];
                
                maskLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(imageView.bounds, 0, 0)].CGPath;
                
                
                
                maskAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
                maskAnimation.fromValue = (__bridge id)([UIBezierPath bezierPathWithOvalInRect:CGRectInset(imageView.bounds, 200, 200)].CGPath);
                maskAnimation.toValue = (__bridge id)([UIBezierPath bezierPathWithOvalInRect:CGRectInset(imageView.bounds, 0, 0)].CGPath);
                maskAnimation.duration = 0.7;
//                maskLayer.fillColor = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
                imageView.layer.mask = maskLayer;
                maskAnimation.delegate = self;

                [maskLayer addAnimation:maskAnimation forKey:@"path"];
                
                maskAnimation.delegate = self;
                
                static NSInteger index = 0;
    
                UIImage *img= [UIImage imageNamed: index%2? @"3.png": @"5.png"];
                
                snopShotLayer = [CALayer layer];
                snopShotLayer.contents = (__bridge id)([UIImage imageNamed: (index+1)%2? @"3.png": @"5.png"].CGImage);
                snopShotLayer.frame = imageView.bounds;
                [imageCell.contentView.layer insertSublayer:snopShotLayer below: imageView.layer];
                
                
                
                imageView.image = img;
                index ++;
            }
            
        }];
        
        
    }
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    if (gestureRecognizer == self.collectionView.panGestureRecognizer &&
        otherGestureRecognizer == pan) {
        return YES;
    }
    return NO;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    CGPoint initialPinchPoint = [touch locationInView:self.collectionView];
    NSIndexPath* pinchedCellPath = [self.collectionView indexPathForItemAtPoint:initialPinchPoint];

    if (pinchedCellPath && pinchedCellPath.section == 1) {
        return YES;
    }
    return NO;
}

#pragma mark CoreAnimation

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    [maskLayer removeFromSuperlayer];
    [snopShotLayer removeFromSuperlayer];
}

-(void)animationDidStart:(CAAnimation *)anim{
    NSLog(@"animation start");
}

@end
