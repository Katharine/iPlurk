//
//  PlurkTableCell.h
//  iPlurk
//
//  Created on 11/10/2008.
//  Copyright 2008 AjaxLife Developments. All rights reserved.
//

#import "Plurk.h"

@protocol PlurkTableCellProtocol

@required
- (void)displayPlurk:(Plurk *)plurk;
@end
