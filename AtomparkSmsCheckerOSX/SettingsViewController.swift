//
//  SettingsViewController.swift
//  AtomparkSmsChecker
//
//  Created by Stanislav Sidelnikov on 26/11/15.
//
//

import Cocoa
import AtomparkKitOSX

class SettingsViewController: NSViewController {
    @IBOutlet weak var usernameTextField: NSTextField!
    @IBOutlet weak var passwordTextField: NSTextField!
    @IBOutlet weak var infoLabel: NSTextField!
    
    override func viewDidLoad() {
        let (username, password) = APUserCredentials.getSavedCredentials()
        
        usernameTextField.stringValue = username ?? ""
        passwordTextField.stringValue = password ?? ""
    }

    @IBAction func login(sender: AnyObject?) {
        self.infoLabel.stringValue = ""
        let login = APLogin()
        do {
            let username = usernameTextField.stringValue
            let password = passwordTextField.stringValue
            try login.performLoginForUser(username, withPassword: password, completion: {(success: Bool, error: NSError?) -> Void in
                if success {
                    self.infoLabel.stringValue = "Login successful."
                    APUserCredentials.saveUsername(username, withPassword: password)
                } else if error != nil {
                    self.infoLabel.stringValue = "Login failed. \(error!.description)."
                } else {
                    self.infoLabel.stringValue = "Login failed. Check credentials."
                }
            })
        } catch {
            
        }
    }
}
