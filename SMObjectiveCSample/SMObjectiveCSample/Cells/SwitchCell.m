//
//  SwitchCell.m
//  SMObjectiveCSample
//

#import "SwitchCell.h"

@interface SwitchCell ()

@property ConfigId backingConfigId;

@end

@implementation SwitchCell

@synthesize backingConfigId;

+ (NSString *) identifier
{
    return NSStringFromClass(SwitchCell.self);
}

- (void) prepareForReuse
{
    [super prepareForReuse];
    [self.switchItem setSelected:true];
    [self.switchLabel setText:@""];
    
    [self setUserInteractionEnabled:true];
    [self.switchLabel setTextColor:UIColor.labelColor];
}

- (void) setConfigId:(ConfigId) configId
{
    self.backingConfigId = configId;
    NSString *defaultsIdentifier = [Enums labelFromConfigId:self.backingConfigId];
    [self.switchLabel setText:NSLocalizedString(defaultsIdentifier, nil)];

    BOOL isEnabled = [NSUserDefaults.standardUserDefaults boolForKey:defaultsIdentifier];
    [self.switchItem setOn:isEnabled animated:false];
}

- (void) didTouchCell
{
    NSString *defaultsIdentifier = [Enums labelFromConfigId:self.backingConfigId];
    BOOL isEnabled = ![NSUserDefaults.standardUserDefaults boolForKey:defaultsIdentifier];
    [self.switchItem setOn:isEnabled animated:true];
    [NSUserDefaults.standardUserDefaults setBool:isEnabled forKey:defaultsIdentifier];
}

- (void) updateContent
{
    [super updateContent];
    [self.switchLabel setTextColor:([self isUserInteractionEnabled] ? UIColor.labelColor : UIColor.secondaryLabelColor)];
}

@end
