//
//  InputCell.swift
//  SMSwiftSample
//

import UIKit

class InputCell: UITableViewCell {
    static let identifier = String(describing: InputCell.self)
    
    @IBOutlet private weak var inputField: UITextField?
    @IBOutlet private weak var inputLabel: UILabel?
    
    private var configId: ConfigId?
    
    override func prepareForReuse() {
        self.inputField?.text = ""
        self.inputLabel?.text = ""
    }
    
    func set(configId: ConfigId) {
        self.configId = configId
        self.inputLabel?.text = NSLocalizedString(configId.rawValue, comment: "")
        
        let textContent = UserDefaults.standard.string(forKey: configId.rawValue)
        self.inputField?.text = textContent
    }
}

extension InputCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let textContent = self.inputField?.text, let id = self.configId?.rawValue {
            UserDefaults.standard.set(textContent, forKey: id)
        }
    }
}
