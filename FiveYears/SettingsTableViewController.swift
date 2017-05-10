//
//  SettingsTableViewController.swift
//  FiveYears
//
//  Created by Jan B on 10.05.17.
//  Copyright © 2017 Jan Busse. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var rainSwitch: UISwitch!
    
    @IBOutlet weak var autoReloadSwitch: UISwitch!
    
    @IBOutlet weak var fontSizeLabel: UILabel!
    
    @IBOutlet weak var fontSizeSlider: UISlider! {
        didSet {
            fontSizeLabel.text = String(Int(fontSizeSlider.value))
        }
    }
    
    @IBOutlet weak var mailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    var settings = UserDefaults.standard.getUserSettings()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetUIToSettings()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("disappearing")
        
        // Save the settings before dismissing the settingsVC
        UserDefaults.standard.save(usersettings: settings)
    }
    
    @IBAction func rainSwitchChanged(_ sender: UISwitch) {
        settings.rainEnabled = sender.isOn
    }
    
    @IBAction func autoReloadChanged(_ sender: UISwitch) {
        settings.autoreloadEnabled = sender.isOn
    }
    
    @IBAction func fontSizeSliderChanged(_ sender: UISlider) {
        sender.setValue(sender.value.rounded(), animated: false)
        
        settings.fontSize = Int(sender.value)
        fontSizeLabel.text = String(Int(sender.value))
    }
    
    @IBAction func mailTextFieldEndedEditing(_ sender: UITextField) {
        settings.loginEmail = sender.text
    }
    
    @IBAction func passwordTextFieldEndedEditing(_ sender: UITextField) {
        settings.loginPassword = sender.text
    }
    
    @IBAction func resetSettings(_ sender: UIButton) {
        let alert = UIAlertController(title: "Einstellungen zurücksetzen", message: "Willst du wirklich alle Einstellungen zurücksetzen? Deine Login Daten werden ebenfalls zurückgesetzt und müssen erneut eingegeben werden. Ohne gültigen Login können keine Erinnerungen abgerufen werden.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Abbrechen", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Zurücksetzen", style: .destructive, handler: { (alert: UIAlertAction) in
                self.settings = UserSettings()
                self.resetUIToSettings()
            }))
        present(alert, animated: true, completion: nil)
    }
    
    private func resetUIToSettings() {
        if let size = settings.fontSize {
            fontSizeSlider.value = Float(size)
        } else {
            fontSizeSlider.value = 17.0
        }
        if let rain = settings.rainEnabled {
            rainSwitch.isOn = rain
        } else {
            rainSwitch.isOn = true
        }
        if let auto = settings.autoreloadEnabled {
            autoReloadSwitch.isOn = auto
        } else {
            autoReloadSwitch.isOn = true
        }
        if let mail = settings.loginEmail {
            mailTextField.text = mail
        }
        if let pswd = settings.loginPassword {
            passwordTextField.text = pswd
        }
    }

}
