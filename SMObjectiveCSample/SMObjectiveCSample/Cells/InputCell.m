//
//  InputCell.m
//  SMObjectiveCSample
//

#import "InputCell.h"

@interface InputCell () <UITextFieldDelegate>

@property ConfigId backingConfigId;

@end

@implementation InputCell

@synthesize backingConfigId;

+ (NSString *) identifier
{
    return NSStringFromClass(InputCell.self);
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.inputField setText:@""];
    [self.inputLabel setText:@""];
}

- (void) setConfigId:(ConfigId) configId
{
    self.backingConfigId = configId;
    NSString *defaultsIdentifier = [Enums labelFromConfigId:self.backingConfigId];
    [self.inputLabel setText:NSLocalizedString(defaultsIdentifier, nil)];

    NSString *textContent = [NSUserDefaults.standardUserDefaults stringForKey:defaultsIdentifier];
    [self.inputField setText:textContent];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSString *textContent = self.inputField.text;
    NSString *defaultsIdentifier = [Enums labelFromConfigId:self.backingConfigId];
    
    [NSUserDefaults.standardUserDefaults setObject:textContent forKey:defaultsIdentifier];
}

@end

