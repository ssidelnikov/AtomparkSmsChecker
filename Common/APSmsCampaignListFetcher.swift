//
//  APSmsCampaignListFetcher.swift
//  AtomparkSmsChecker
//
//  Created by Stanislav Sidelnikov on 27/11/15.
//
//

import Foundation
import HTMLReader

public class APSmsCampaignListFetcher : NSObject {
    lazy var urlSession = NSURLSession.sharedSession()
    lazy var urlDateFormatter : NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    func getNetworkerForPage(page: Int, startDate: NSDate, endDate: NSDate) -> APNetworker {
        return APNetworker(session: NSURLSession.sharedSession(), path: "/members/sms/stat/my-index/page/\(page)/onPage/50/startDate/\(urlDateFormatter.stringFromDate(startDate))/endDate/\(urlDateFormatter.stringFromDate(endDate))/orderfield/delivered/order/1/")
    }
    
    var campaigns = [APSmsCampaign]()
    var fetchCompletionHandler : (([APSmsCampaign], error: NSError?)->Void)?
    
    public func getCampaignsForPreviousDays(days:Int, completion: (([APSmsCampaign], error: NSError?)->Void)) {
        campaigns.removeAll()
        fetchCompletionHandler = completion
        fetchCampaignsForDays(days, page: 1, completion: appendCampaigns)
    }
    
    func appendCampaigns(campaigns: [APSmsCampaign]?, days: Int, page: Int, error: NSError?) {
        guard campaigns != nil else {
            if fetchCompletionHandler != nil {
                fetchCompletionHandler!(self.campaigns, error: error)
            }
            return
        }
        
        let failedCampaigns = campaigns!.filter { !$0.delivered }
        self.campaigns.appendContentsOf(failedCampaigns)
        
        if failedCampaigns.count > 0 && failedCampaigns.count == campaigns!.count {
            // All the elements of the current page are failed campaigns so request the next page
            fetchCampaignsForDays(days, page: page + 1, completion: appendCampaigns)
        } else {
            // We've riched the end of the failed campaigns' list
            self.campaigns.sortInPlace({ (firstElement, secondElement) -> Bool in
                return firstElement.date.isGreaterThan(secondElement.date)
            })
            
            guard self.fetchCompletionHandler != nil else {
                print("There's no completion handler for getCampaignsForPreviousDays function!")
                return
            }
            
            self.fetchCompletionHandler!(self.campaigns, error: nil)
        }
    }
    
    func fetchCampaignsForDays(days: Int, page: Int, completion: ((campaigns: [APSmsCampaign]?, days: Int, page: Int, error: NSError?)->Void)) {
        let calendar = NSCalendar.currentCalendar()
        let endDate = NSDate()
        let startDate = calendar.dateByAddingUnit(.Day, value: -1 * days, toDate: endDate, options: [])!
        let networker = getNetworkerForPage(page, startDate: startDate, endDate: endDate)
        do {
            try networker.fetchParameters(nil, completion: {(data, error) in
                guard let nsData = data as? NSData else {
                    let error = NSError(domain: "campaign.list.fetcher", code: 501, userInfo: ["description": "Unable to get NSData from data"])
                    completion(campaigns: nil, days: days, page: page, error: error)
                    return
                }
                guard let htmlData = String(data: nsData, encoding: NSUTF8StringEncoding) else {
                    let error = NSError(domain: "campaign.list.fetcher", code: 502, userInfo: ["description": "Unable to decode NSDate to HTML"])
                    completion(campaigns: nil, days: days, page: page, error: error)
                    return
                }
                
                let htmlDoc = HTMLDocument(string: htmlData)
                
                let rows = htmlDoc.nodesMatchingSelector("table.campaigns-list td > .row")
                
                let atomparkDateFormatter = NSDateFormatter()
                atomparkDateFormatter.dateFormat = "dd MMMM yyyy г. HH:mm"
                atomparkDateFormatter.locale = NSLocale(localeIdentifier: "ru_RU")
                atomparkDateFormatter.timeZone = NSTimeZone(name: "Asia/Yekaterinburg")
                
                var campaignList = [APSmsCampaign]()
                
                for row in rows {
                    guard let rowElement = row as? HTMLElement else {
                        continue
                    }
                    guard let basicInfoDivElement = rowElement.firstNodeMatchingSelector(".item-heading")?.parentNode else {
                        continue
                    }
                    guard basicInfoDivElement.childElementNodes.count > 2 else {
                        continue
                    }
                    let dateString = basicInfoDivElement.childElementNodes[1].textContent!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    let phoneNumberString = basicInfoDivElement.childElementNodes[2].textContent!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    let messageText = rowElement.firstNodeMatchingSelector(".msg_text")!.textContent.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    let delivered = (rowElement.firstNodeMatchingSelector(".color-info")?.textContent ?? "1") == (rowElement.firstNodeMatchingSelector(".color-success")?.textContent ?? "0")
                    
                    let campaingLinkHrefParts = rowElement.firstNodeMatchingSelector(".item-heading a")?.objectForKeyedSubscript("href")!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).componentsSeparatedByString("/")
                    let campaignId = campaingLinkHrefParts![5]
                    
                    let date = atomparkDateFormatter.dateFromString(dateString)!
                    
                    let smsCampaign = APSmsCampaign(campaignId: campaignId, phoneNumber: phoneNumberString, date: date, text: messageText)
                    smsCampaign.delivered = delivered
                    
                    campaignList.append(smsCampaign)
                }
                completion(campaigns: campaignList, days: days, page: page, error: nil)
            })
        } catch let errorType {
            let error = NSError(domain: "campaign.list.fetcher", code: 500, userInfo: ["description": "Unexpected error: \(errorType)"])
            completion(campaigns: nil, days: days, page: page, error: error)
        }
    }
}