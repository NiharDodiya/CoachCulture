//
//  PaymentModel.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 24/12/21.
//

import Foundation


class SubsciptionList {
    var map: Map!
    var id = ""
    var username = ""
    var user_image = ""
    var monthly_subscription_fee = ""
    var start_subscription_date = ""
    var end_subscription_date = ""
    var coach_status = ""
    var followers = ""
    var endDate = ""
    var unsubscribe_status = false
    var feesDataObj = FeesData()
    var base_currency = ""
    var amount = ""
    var status = ""
    
    init() {}
    
    init(responseObj: [String : Any]) {
        map = Map(data: responseObj )
        id = map.value("id") ?? ""
        status = map.value("status") ?? ""
        base_currency = map.value("base_currency") ?? ""
        amount = map.value("amount") ?? ""
        username = map.value("username") ?? ""
        unsubscribe_status = map.value("unsubscribe_status") ?? false
        user_image = map.value("user_image") ?? ""
        monthly_subscription_fee = map.value("monthly_subscription_fee") ?? ""
        start_subscription_date = map.value("start_subscription_date") ?? ""
        end_subscription_date = map.value("end_subscription_date") ?? ""
        coach_status = map.value("coach_status") ?? ""
        followers = map.value("followers") ?? ""
        feesDataObj = FeesData(responseObj: responseObj["fees"] as? [String : Any] ?? [String : Any]())
        if !end_subscription_date.isEmpty {
            let nsDate = end_subscription_date.getDateWithFormate(formate: "yyyy-MM-dd hh:mm:ss", timezone: "UTC")
            endDate = nsDate.getDateStringWithFormate("MMM dd, yyyy", timezone: "UTC")
        }


    }
    
    
    class func getData(data : [Any]) -> [SubsciptionList] {
        
        var arrTemp = [SubsciptionList]()
        for temp in data {
       
            arrTemp.append(SubsciptionList(responseObj: temp as? [String : Any] ?? [String : Any]()))
        }
        
        return arrTemp
    }
}
