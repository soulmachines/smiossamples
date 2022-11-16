//
// Copyright (c) 2022 Soul Machines. All rights reserved.
//  SettingsViewController.m
//  SMObjectiveCSample
//

#import <UIKit/UIKit.h>
#import "SettingsViewController.h"
#import "SwitchCell.h"
#import "InputCell.h"
#import "Enums.h"

@interface SettingsViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation SettingsViewController

BOOL isUrlAndTokenSectionEnabled = false;

NSArray *settingHeaders;
NSArray *firstSettingsList;
NSArray *secondSettingsList;

CGFloat switchHeight = 60;
CGFloat inputHeight = 90;

- (void)viewDidLoad
{
    [super viewDidLoad];
    settingHeaders = @[@(APIKey), @(ServerConnectionAccessToken)];
    firstSettingsList = @[@(APIKeyDescription), @(UseUrlAndToken)];
    secondSettingsList = @[@(KeyName), @(PrivateKey), @(EnableOrchestration), @(OrchestrationUrl), @(UseJWT), @(JWTString)];
    
    [self.tableView registerNib:[UINib nibWithNibName:[SwitchCell identifier] bundle:nil] forCellReuseIdentifier:[SwitchCell identifier]];
    [self.tableView registerNib:[UINib nibWithNibName:[InputCell identifier] bundle:nil] forCellReuseIdentifier:[InputCell identifier]];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    isUrlAndTokenSectionEnabled = [NSUserDefaults.standardUserDefaults boolForKey:[Enums labelFromConfigId:UseUrlAndToken]];
}

#pragma mark - Table View Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return settingHeaders.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return firstSettingsList.count;
    }
    else
    {
        return secondSettingsList.count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    HeaderId headerId = (HeaderId) [[settingHeaders objectAtIndex:section] integerValue];
    return NSLocalizedString([Enums labelFromHeaderId:headerId], comment: "");
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        ConfigId setting = (ConfigId) [firstSettingsList[indexPath.row] integerValue];
        SampleCustomCell *cell = [self retrieveCellFromSetting:setting forTable:tableView];
        [cell setUserInteractionEnabled:(setting == APIKeyDescription ? !isUrlAndTokenSectionEnabled : true)];
        [cell updateContent];
        return cell;
    }
    else
    {
        ConfigId setting = (ConfigId) [secondSettingsList[indexPath.row] integerValue];
        SampleCustomCell *cell = [self retrieveCellFromSetting:setting forTable:tableView];
        [cell setUserInteractionEnabled:isUrlAndTokenSectionEnabled];
        [cell updateContent];
        return cell;
    }
}

- (SampleCustomCell *) retrieveCellFromSetting:(ConfigId)setting forTable:(UITableView *)tableView
{
    if ([Enums isConfigIdSwitch:setting])
    {
        SwitchCell *switchCell = [tableView dequeueReusableCellWithIdentifier:[SwitchCell identifier]];
        [switchCell setConfigId:setting];
        [switchCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return switchCell;
    }
    else
    {
        InputCell *inputCell = [tableView dequeueReusableCellWithIdentifier:[InputCell identifier]];
        [inputCell setConfigId:setting];
        [inputCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return inputCell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = switchHeight;
    
    if (indexPath.section == 0)
    {
        if(false == [Enums isConfigIdSwitch:(ConfigId) [[firstSettingsList objectAtIndex:indexPath.row] integerValue]])
        {
            height = inputHeight;
        }
    }
    else
    {
        if(false == [Enums isConfigIdSwitch:(ConfigId) [[secondSettingsList objectAtIndex:indexPath.row] integerValue]])
        {
            height = inputHeight;
        }
    }
    
    return height;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:false];
    ConfigId tableSetting = (indexPath.section == 0) ? (ConfigId)[[firstSettingsList objectAtIndex:indexPath.row] integerValue] :
                                                       (ConfigId)[[secondSettingsList objectAtIndex:indexPath.row] integerValue];
    
    if ([Enums isConfigIdSwitch:tableSetting])
    {
        SwitchCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell didTouchCell];
    }
    
    if (tableSetting == UseUrlAndToken)
    {
        isUrlAndTokenSectionEnabled = [NSUserDefaults.standardUserDefaults boolForKey:[Enums labelFromConfigId:UseUrlAndToken]];
        [tableView reloadData];
    }
}
@end

