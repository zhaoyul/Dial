//
//  CreationLayoutDemo
//
//
//  Created by Kevin Li on 2015.05.20.
//  Copyright (c) 2014 Kevin Li. All rights reserved.
//
//  
//  
//

#import "CreationLayout.h"

@implementation CreationLayout



- (id)init
{
    if ((self = [super init]) != NULL)
    {
		[self setup];
    }
    return self;
}

-(id)initWithRadius: (CGFloat) radius andAngularSpacing: (CGFloat) spacing andCellSize: (CGSize) cell andAlignment:(WheelAlignmentType)alignment andItemHeight:(CGFloat)height andXOffset: (CGFloat) xOff{
    if ((self = [super init]) != NULL)
    {
        self.dialRadius = radius;//420.0f;
        self.cellSize = cell;//(CGSize){ 220.0f, 80.0f };
        self.itemHeight = height;
        self.AngularSpacing = spacing;//8.0f;
        self.xOffset = xOff;
        self.wheelType = alignment;
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.offset = 0.0f;    
}

- (void)prepareLayout
{
    [super prepareLayout];

    self.cellCount = (int)[self.collectionView numberOfItemsInSection:0];
    self.offset = -self.collectionView.contentOffset.y / self.itemHeight;
    
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}


- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *theLayoutAttributes = [[NSMutableArray alloc] init];
    
       for( int i = 0; i <= self.cellCount-1; i++ ){
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        UICollectionViewLayoutAttributes *theAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];
        [theLayoutAttributes addObject:theAttributes];
    }
 
   
    return [theLayoutAttributes copy];
}


- (CGSize)collectionViewContentSize
{
    const CGSize theSize = {
        .width = self.collectionView.bounds.size.width,
        .height = (self.cellCount-1) * self.itemHeight + self.collectionView.bounds.size.height,
    };
    return(theSize);
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    double newIndex = (indexPath.item + self.offset);
    
    UICollectionViewLayoutAttributes *theAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    theAttributes.size = self.cellSize;
    float scaleFactor;
    float deltaX;
    CGAffineTransform translationT;
    CGAffineTransform rotationT = CGAffineTransformMakeRotation(self.AngularSpacing* newIndex *M_PI/180);
    if(indexPath.item == 3){
        NSLog(@"angle 3 :%f", self.AngularSpacing* newIndex);
    }
    
    
    if( self.wheelType == WHEELALIGNMENTLEFT){
        scaleFactor = fmax(1, 1 - fabs( newIndex *0.25));
        deltaX = self.cellSize.width/2;
        theAttributes.center = CGPointMake(-self.dialRadius + self.xOffset  , self.collectionView.bounds.size.height/2 + self.collectionView.contentOffset.y);
        translationT =CGAffineTransformMakeTranslation(self.dialRadius + (deltaX*scaleFactor) , 0);
    }else  {
        scaleFactor = fmax(0.4, 1 - fabs( newIndex *0.50));
        deltaX =  self.collectionView.bounds.size.width/2;
        theAttributes.center = CGPointMake(-self.dialRadius + self.xOffset , self.collectionView.bounds.size.height/2 + self.collectionView.contentOffset.y);
        translationT =CGAffineTransformMakeTranslation(self.dialRadius  + ((1 - scaleFactor) * -30) , 0);
    }
    
    
    
    CGAffineTransform scaleT = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
    theAttributes.alpha = scaleFactor;
    
    
    theAttributes.transform = CGAffineTransformConcat(scaleT, CGAffineTransformConcat(translationT, rotationT));
    theAttributes.zIndex = indexPath.item;
    
    
    [self applyPinchToLayoutAttributes:theAttributes];
    
    if( self.AngularSpacing* newIndex > 260 || self.AngularSpacing * newIndex < -30){
        theAttributes.center = CGPointMake(400, -200);
    }else{
        theAttributes.hidden = NO;
    }
    
    return(theAttributes);
}

-(void)setPinchedCellScale:(CGFloat)scale
{
    _pinchedCellScale = scale;
    [self invalidateLayout];
}

- (void)setPinchedCellCenter:(CGPoint)origin {
    _pinchedCellCenter = origin;
    [self invalidateLayout];
}

-(void)applyPinchToLayoutAttributes:(UICollectionViewLayoutAttributes*)layoutAttributes
{
    if ([layoutAttributes.indexPath isEqual:self.pinchedCellPath])
    {
        layoutAttributes.transform3D = CATransform3DMakeScale(self.pinchedCellScale, self.pinchedCellScale, 1.0);
        layoutAttributes.center = self.pinchedCellCenter;
        layoutAttributes.zIndex = 1;
    }
}



@end
