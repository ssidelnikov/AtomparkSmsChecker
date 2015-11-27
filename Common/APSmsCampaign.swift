//
//  APSmsCampaign.swift
//  AtomparkSmsChecker
//
//  Created by Stanislav Sidelnikov on 27/11/15.
//
//

import Foundation

public class APSmsCampaign: NSObject {
    public internal(set) var campaignId: String
    public var phoneNumber: String
    public var date: NSDate
    public var text: String
    public var delivered = false
    
    public override var description : String {
        return "Message \"\(date)\" to \"\(phoneNumber)\" (campaign \(campaignId)): \"\(text)\". Delivered: \(delivered)."
    }
    
    init(campaignId: String, phoneNumber: String, date: NSDate, text: String) {
        self.campaignId = campaignId
        self.phoneNumber = phoneNumber
        self.date = date
        self.text = text
    }
    
    
}
