//
//  SwitchCell.h
//  SMObjectiveCSample
//

#import <UIKit/UIKit.h>
#import "Enums.h"

@interface SwitchCell: UITableViewCell

@property (weak, nonatomic) IBOutlet UISwitch *switchItem;
@property (weak, nonatomic) IBOutlet UILabel *switchLabel;

+ (NSString *) identifier;

- (void) setConfigId:(ConfigId) configId;
- (void) didTouchCell;

@end

