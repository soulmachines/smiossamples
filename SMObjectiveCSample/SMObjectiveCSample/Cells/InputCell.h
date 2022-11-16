//
// Copyright (c) 2022 Soul Machines. All rights reserved.
//  InputCell.h
//  SMObjectiveCSample
//

#import <UIKit/UIKit.h>
#import "SampleCustomCell.h"
#import "Enums.h"

@interface InputCell: SampleCustomCell

@property (weak, nonatomic) IBOutlet UITextField *inputField;
@property (weak, nonatomic) IBOutlet UILabel *inputLabel;

+ (NSString *) identifier;

- (void) setConfigId:(ConfigId) configId;

@end
