//
//  APCampaignsViewController.swift
//  AtomparkSmsChecker
//
//  Created by Stanislav Sidelnikov on 27/11/15.
//
//

import Cocoa
import AtomparkKitOSX

class APCampaignsViewController: NSViewController {
    @IBOutlet weak var getCampaignsButton: NSButton!
    
    @IBAction func checkLogin(sender: AnyObject) {
        let login = APLogin()
        if login.loggedIn {
            print("User is logged in")
        } else {
            print("User is not logged in")
        }
    }
    
    @IBAction func getCampaigns(sender: AnyObject) {
        getCampaignsButton.enabled = false
        let login = APLogin()
        if !login.loggedIn {
            let (username, password) = APUserCredentials.getSavedCredentials()
            guard username != nil && password != nil else {
                print("Unable to get campaigns. You are not logged in, nor provided the credentials.")
                self.getCampaignsButton.enabled = false
                return
            }
            do {
                try login.performLoginForUser(username!, withPassword: password!, completion: { (success, error) -> Void in
                    guard success else {
                        print("Unable to login with the saved credentials. \(error)")
                        self.getCampaignsButton.enabled = false
                        return
                    }
                    self.loadCampaigns()
                })
            } catch let error {
                self.getCampaignsButton.enabled = false
                print("Unable to initiate login. \(error)")
            }
            return
        }
        loadCampaigns()
    }
    
    func loadCampaigns() {
        let fetcher = APSmsCampaignListFetcher()
        fetcher.getCampaignsForPreviousDays(3) { (campaigns, error) -> Void in
            self.getCampaignsButton.enabled = true
            guard error == nil else {
                print("There was an error fetching campaings. \(error)")
                return
            }
            print(campaigns)
            print(campaigns.count)
        }
    }
}
