//
// Copyright (c) 2021 Soul Machines. All rights reserved.
//  SwitchCell.swift
//  SMSwiftSample
//

import UIKit

class SwitchCell: SampleCustomCell {
    static let identifier = String(describing: SwitchCell.self)
    
    @IBOutlet private weak var switchItem: UISwitch?
    @IBOutlet private weak var switchLabel: UILabel?
    
    private var configId: ConfigId?
    
    override func prepareForReuse() {
        self.switchItem?.isSelected = true
        self.switchLabel?.text = ""
        
        self.switchLabel?.textColor = UIColor.label
        self.isUserInteractionEnabled = true
    }
    
    func set(configId: ConfigId) {
        self.configId = configId
        self.switchLabel?.text = NSLocalizedString(configId.rawValue, comment: "")
        
        let isEnabled = UserDefaults.standard.bool(forKey: configId.rawValue)
        self.switchItem?.setOn(isEnabled, animated: false)
    }
    
    func didTouchCell() {
        if let id = self.configId?.rawValue {
            let isEnabled = !(UserDefaults.standard.bool(forKey: id))
            self.switchItem?.setOn(isEnabled, animated: true)
            UserDefaults.standard.set(isEnabled, forKey: id)
        }
    }
    
    override func updateContent() {
        super.updateContent()
        self.switchLabel?.textColor = self.isUserInteractionEnabled ? .label : .secondaryLabel
    }
}

