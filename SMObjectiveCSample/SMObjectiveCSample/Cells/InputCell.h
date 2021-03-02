//
//  InputCell.h
//  SMObjectiveCSample
//

#import <UIKit/UIKit.h>
#import "Enums.h"

@interface InputCell: UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *inputField;
@property (weak, nonatomic) IBOutlet UILabel *inputLabel;

+ (NSString *) identifier;

- (void) setConfigId:(ConfigId) configId;

@end
