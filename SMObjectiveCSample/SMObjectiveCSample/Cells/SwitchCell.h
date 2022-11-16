//
// Copyright (c) 2021 Soul Machines. All rights reserved.
//  SwitchCell.h
//  SMObjectiveCSample
//

#import <UIKit/UIKit.h>
#import "SampleCustomCell.h"
#import "Enums.h"

@interface SwitchCell: SampleCustomCell

@property (weak, nonatomic) IBOutlet UISwitch *switchItem;
@property (weak, nonatomic) IBOutlet UILabel *switchLabel;

+ (NSString *) identifier;

- (void) setConfigId:(ConfigId) configId;
- (void) didTouchCell;

@end

