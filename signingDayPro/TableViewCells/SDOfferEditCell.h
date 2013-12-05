//
//  SDOfferEditCell.h
//  SigningDay
//
//  Created by Lukas Kekys on 12/2/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Offer;

@interface SDOfferEditCell : UITableViewCell

- (void)setupCellWithOffer:(Offer *)offer andPlayerCommitted:(BOOL)committed;

@end
