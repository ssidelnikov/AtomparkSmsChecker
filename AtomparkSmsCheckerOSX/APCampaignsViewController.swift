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
    @IBOutlet weak var campaignsTableView: NSTableView!
    @IBOutlet weak var getCampaignsButton: NSButton!
    @IBOutlet weak var daysTextField: NSTextField!
    var campaignsList = [APSmsCampaign]()
    
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
        var days = daysTextField.integerValue
        if days <= 0 {
            days = 1
            daysTextField.integerValue = days
        }
        fetcher.getCampaignsForPreviousDays(days) { (campaigns, error) -> Void in
            guard error == nil else {
                print("There was an error fetching campaings. \(error)")
                return
            }
            self.campaignsList = campaigns
            dispatch_async(dispatch_get_main_queue(), {
                self.getCampaignsButton.enabled = true
                self.campaignsTableView.reloadData()
            })
        }
    }
    
}

// MARK: - NSTableViewDataSource
extension APCampaignsViewController: NSTableViewDataSource {
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return self.campaignsList.count
    }
    
}

// MARK: - NSTableViewDelegate
extension APCampaignsViewController: NSTableViewDelegate {
    var dateFormatter : NSDateFormatter {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "Asia/Yekaterinburg")
        dateFormatter.locale = NSLocale(localeIdentifier: "ru_RU")
        dateFormatter.dateFormat = "dd MMMM yyyy г. HH:mm"
        return dateFormatter
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellView = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: self) as! NSTableCellView
        
        let campaign = self.campaignsList[row]
        let rowData = ["Date": dateFormatter.stringFromDate(campaign.date), "Phone": campaign.phoneNumber, "Order No": campaign.orderNumber]
        if let value = rowData[tableColumn!.identifier] {
            cellView.textField!.stringValue = value
        }
        return cellView
    }
}
