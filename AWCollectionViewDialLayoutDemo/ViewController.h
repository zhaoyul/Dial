//
//  ViewController.h
//  CreationLayoutDemo
//
//  Created by Kevin Li on 2015.05.20
//  Copyright (c) 2015 Kevin Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *editBtn;
@property NSArray *items;
@end
