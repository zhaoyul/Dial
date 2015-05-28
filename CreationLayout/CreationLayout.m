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

-(id)initWithRadius: (CGFloat) radius andAngularSpacing: (CGFloat) spacing andCellSize: (CGSize) cell andItemHeight:(CGFloat)height {
    if ((self = [super init]) != NULL)
    {
        self.dialRadius = radius;
        self.cellSize = cell;
        self.itemHeight = height;
        self.AngularSpacing = spacing;
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
    
    self.circleCellCount = (int)[self.collectionView numberOfItemsInSection:1];
    self.offset = -self.collectionView.contentOffset.y / self.itemHeight;
    
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}


- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *theLayoutAttributes = [[NSMutableArray alloc] init];
    
    for( int i = 0; i <= self.circleCellCount-1; i++ ){
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:1];
        UICollectionViewLayoutAttributes *theAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];
        [theLayoutAttributes addObject:theAttributes];
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    UICollectionViewLayoutAttributes *theAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];
    
    [theLayoutAttributes addObject:theAttributes];
    
    return [theLayoutAttributes copy];
}


- (CGSize)collectionViewContentSize
{
    
#define LAST_ELEMENT_NUMBER 6
    const CGSize theSize = {
        .width = self.collectionView.bounds.size.width,
        .height = (self.circleCellCount-LAST_ELEMENT_NUMBER) * self.itemHeight +
        self.collectionView.bounds.size.height,
    };
    return(theSize);
}

- (UICollectionViewLayoutAttributes *)attributeForClothSecion:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *resultAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    resultAttributes.size = self.imageSize;
    resultAttributes.center = CGPointMake(self.collectionView.bounds.size.width/2, self.collectionView.bounds.size.height/2 + self.collectionView.contentOffset.y);
    
    return resultAttributes;
}


- (UICollectionViewLayoutAttributes *)attributeForCircleSecion:(NSIndexPath *)indexPath
{
    double currentIndex = (indexPath.item + self.offset);
    
    UICollectionViewLayoutAttributes *resultAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    resultAttributes.size = self.cellSize;
    CGAffineTransform translationT;
    CGAffineTransform rotationT = CGAffineTransformMakeRotation(self.AngularSpacing* currentIndex *M_PI/180);
    
    
    
    resultAttributes.center = CGPointMake(self.collectionView.bounds.size.width/2  , self.collectionView.bounds.size.height/2 + self.collectionView.contentOffset.y);
    translationT =CGAffineTransformMakeTranslation(self.dialRadius , 0);
    
    resultAttributes.transform =  CGAffineTransformConcat(translationT, rotationT);
    resultAttributes.zIndex = indexPath.item;
    
    
    [self applyPinchToLayoutAttributes:resultAttributes];
    
#define VERY_FAR CGPointMake(1000000, 1000000)
    
    if( self.AngularSpacing* currentIndex > 260 || self.AngularSpacing * currentIndex < -30){
        resultAttributes.center = VERY_FAR;
    }
    
    return resultAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *resultAttributes;
    if (indexPath.section == 1) {
        resultAttributes = [self attributeForCircleSecion:indexPath];
    } else {
        resultAttributes = [self attributeForClothSecion:indexPath];
        
    }
    
    return(resultAttributes);
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
