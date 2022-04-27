//
//  CommonSubscription_Const.swift
//  Common_Subscripton_Code
//
//  Created by iOS on 30/03/22.
//

import Foundation
import UIKit
import Purchases

internal struct CSConst
{
    internal struct csInitProductInfo
    {
        var identifire : String
        var revenuecatEntName : String
        var tag : String
    }
    
    internal struct csInitProduct
    {
        var revenuecatApiKey : String
        var allProduct : [csInitProductInfo]
    }
    
    internal enum csError : String
    {
        case noInterNet = "Internet connection not available,please turn on mobile data or wifi."
        case server = "Server Error,please try again after some time"
        case unknown = "An unknown error occurred,please try again after some time"
        case tagNotFound = "Given product tag not found."
        case identifireNotFound = "Given product identifire not found."
        case nothingForRestore = "Restore failed Or Nothing to Restore."
        case purchaseFailed = "Purchase Failed Or Something went wrong."
        case lastPurchaseNotFound = "Last Purchase Not Found."
    }
    
    internal struct csProductInfo
    {
        var tag : String
        var identifire : String
        var price_String : String
        var price : Double
        var currencyCode : String
        var freeTrail : csProductFreeTrailInfo
    }
    
    internal struct csProductFreeTrailInfo
    {
        var isEnabled : Bool
        var duration : Int
        var unit : SKProduct.PeriodUnit
    }
}

