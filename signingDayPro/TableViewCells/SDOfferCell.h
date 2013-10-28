//
//  SDOfferCell.h
//  SigningDay
//
//  Created by Lukas Kekys on 10/24/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Offer;

@interface SDOfferCell : UITableViewCell

- (void)setupCellWithOffer:(Offer *)offer;

@end
