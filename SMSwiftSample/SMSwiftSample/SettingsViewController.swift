//
//  SettingsViewController.swift
//  SMSwiftSample
//

import UIKit

class SettingsViewController: UIViewController {
    static let switchHeight: CGFloat = 60
    static let inputHeight: CGFloat = 90
    
    @IBOutlet private weak var tableView: UITableView?
    
    let settingHeaders: [HeaderId] = [.APIKey, .ServerConnectionAccessToken]
    let firstSettingsList: [ConfigId] = [.APIKeyDescription, .UseUrlAndToken]
    let secondSettingsList: [ConfigId] = [.ServerUrl, .KeyName, .PrivateKey, .EnableOrchestration, .OrchestrationUrl, .UseJWT, .JWT]
    
    override func viewDidLoad() {
        self.tableView?.register(UINib(nibName: SwitchCell.identifier, bundle: nil), forCellReuseIdentifier: SwitchCell.identifier)
        self.tableView?.register(UINib(nibName: InputCell.identifier, bundle: nil), forCellReuseIdentifier: InputCell.identifier)
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.section == 1 {
            if self.secondSettingsList[indexPath.row].isSwitch() {
                let cell = tableView.cellForRow(at: indexPath) as? SwitchCell
                cell?.didTouchCell()
            }
        }
    }
}

extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.settingHeaders.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? self.firstSettingsList.count : self.secondSettingsList.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString(self.settingHeaders[section].rawValue, comment: "")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let setting = self.firstSettingsList[indexPath.row]
            return self.retrieveCell(fromSetting: setting, forTable: tableView)
        } else {
            let setting = self.secondSettingsList[indexPath.row]
            return self.retrieveCell(fromSetting: setting, forTable: tableView)
        }
    }
    
    private func retrieveCell(fromSetting setting: ConfigId, forTable tableView: UITableView) -> UITableViewCell {
        if setting.isSwitch() {
            if let cell = tableView.dequeueReusableCell(withIdentifier: SwitchCell.identifier) as? SwitchCell {
                cell.set(configId: setting)
                cell.selectionStyle = .none
                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: InputCell.identifier) as? InputCell {
                cell.set(configId: setting)
                cell.selectionStyle = .none
                return cell
            }
        }
        
        debugPrint("Returning basic cell")
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = SettingsViewController.switchHeight
        
        if indexPath.section == 0 {
            if false == self.firstSettingsList[indexPath.row].isSwitch() {
                height = SettingsViewController.inputHeight
            }
        } else {
            if false == self.secondSettingsList[indexPath.row].isSwitch() {
                height = SettingsViewController.inputHeight
            }
        }
        
        return height
    }
}
