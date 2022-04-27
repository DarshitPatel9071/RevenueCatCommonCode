//
//  CommonSubscription.swift
//  Common_Subscripton_Code
//
//  Created by iOS on 30/03/22.
//

import Foundation
import Purchases
import Reachability

// ---------------------------------------------------------------------------------------------------------
// MARK:- CommonSubscription Class
// ---------------------------------------------------------------------------------------------------------

public class CommonSubscription: NSObject
{
    // -------------------------------------------------
    // MARK:- All Varible's
    // -------------------------------------------------
    static var shared : CommonSubscription = CommonSubscription()
    
    private var initInfo : CSConst.csInitProduct!
}

// -------------------------------------------------
// MARK:- get all product info from user
// -------------------------------------------------
extension CommonSubscription
{
    func initCommonSubscription(_ info : CSConst.csInitProduct)
    {
        initInfo = info
        CSRevenueCat.sharedRC.initRevenueCat(initInfo)
    }
}

// -------------------------------------------------
// MARK:- Get Single Product info and show error
// -------------------------------------------------
extension CommonSubscription
{
    // for get single product info
    func getProductInfo(_ tag : String,
                        _ completion : @escaping ((_ planInfo : CSConst.csProductInfo?,
                                                   _ err : CSConst.csError?) -> Void))
    {
        checkTagAndInternet(tag) { (index, err) in
            
            if err == nil
            {
                UIApplication.CSGetTopVC()!.CS_startLoader()
                
                CSRevenueCat.sharedRC.getProductInfo(index!)
                {
                   (product,err) in
                    
                    UIApplication.CSGetTopVC()!.CS_stopLoader()
                    
                    if err != nil
                    {
                        UIApplication.CSGetTopVC()!.CSShowErrorAlert("Error", err!.rawValue)
                        {
                            completion(nil,err)
                        }
                    }
                    else
                    {
                        completion(product!,nil)
                    }
                }
            }
            else
            {
                UIApplication.CSGetTopVC()!.CSShowErrorAlert("Error", err!.rawValue)
                {
                    completion(nil,err)
                }
            }
        }
    }
    
    // get index for given product tag or check internet connected
    private func checkTagAndInternet(_ tag : String,
                                     _ completion : @escaping ((_ planIndex : Int?,
                                                                _ err : CSConst.csError?) -> Void))
    {
        if let planIndex = initInfo.allProduct.firstIndex(where: {$0.tag.lowercased() == tag.lowercased()})
        {
            completion(planIndex,nil)
            return
        }
        
        completion(nil,CSConst.csError.tagNotFound)
    }
}

// -------------------------------------------------
// MARK:- Get All Product info and show error
// -------------------------------------------------
extension CommonSubscription
{
    func getProductInfo(_ completion : @escaping ((_ planInfo : [CSConst.csProductInfo]?,
                                                   _ err : CSConst.csError?) -> Void))
    {
        var tempArrAllProduct = [CSConst.csProductInfo]()
        UIApplication.CSGetTopVC()?.CS_startLoader()
        
        for productIhndex in 0..<initInfo.allProduct.count
        {
            CSRevenueCat.sharedRC.getProductInfo(productIhndex)
            {
               [self](product,err) in
                
                UIApplication.CSGetTopVC()?.CS_stopLoader()
                
                if err != nil
                {
                    UIApplication.CSGetTopVC()?.CSShowErrorAlert("Error", err!.rawValue)
                    {
                        completion(nil,err)
                    }
                    
                    return
                }
                else
                {
                    tempArrAllProduct.append(product!)
                    
                    if tempArrAllProduct.count == initInfo.allProduct.count
                    {
                        completion(tempArrAllProduct,nil)
                    }
                }
            }
        }
    }
}


// -------------------------------------------------
// MARK:- Purchase New Product
// -------------------------------------------------
extension CommonSubscription
{
    func purchaseProduct(_ prodcutInfo : CSConst.csProductInfo,
                         _ completion : @escaping(_ error:CSConst.csError?)->Void)
    {
        if CSNetConnection.shared.isConnected()
        {
            
            UIApplication.CSGetTopVC()?.CS_startLoader()
            
            CSRevenueCat.sharedRC.purchaseByRC(prodcutInfo)
            {
                (err) in
                UIApplication.CSGetTopVC()?.CS_stopLoader()
                completion(err)
            }
        }
        else
        {
            completion(.noInterNet)
        }
    }
}

// -------------------------------------------------
// MARK:- Restore Old Purchses
// -------------------------------------------------
extension CommonSubscription
{
    func restoreProduct(_ completion : @escaping(_ error:CSConst.csError?)->Void)
    {
        if CSNetConnection.shared.isConnected()
        {
            UIApplication.CSGetTopVC()?.CS_startLoader()
            
            CSRevenueCat.sharedRC.restoreByRC
            {
                (err) in
                UIApplication.CSGetTopVC()?.CS_stopLoader()
                completion(err)
            }
        }
        else
        {
            completion(.noInterNet)
        }
    }
}

// -------------------------------------------------
// MARK:- Get Old Purchases
// -------------------------------------------------
extension CommonSubscription
{
    func checkLastPurchase(_ completion : @escaping ((_ err : CSConst.csError?) -> Void))
    {
        UIApplication.CSGetTopVC()?.CS_startLoader()
        CSRevenueCat.sharedRC.syncPurchaseByRC
        {
            (error) in
            
            UIApplication.CSGetTopVC()?.CS_stopLoader()
            completion(error)
        }
    }
}














// ---------------------------------------------------------------------------------------------------------
// MARK:- CSRevenueCat Class
// ---------------------------------------------------------------------------------------------------------

fileprivate class CSRevenueCat: NSObject
{
    // -------------------------------------------------
    // MARK:- All Varible's
    // -------------------------------------------------
    
    static var sharedRC : CSRevenueCat = CSRevenueCat()
    
    private var initInfo : CSConst.csInitProduct!
    private var currentProductInfo : Purchases.PurchaserInfo?
    private var allAvailableProduct = [Purchases.Package]()
}

// -------------------------------------------------
// MARK:- Init RevenueCat
// -------------------------------------------------

fileprivate extension CSRevenueCat
{
    // init RevenueCat
    func initRevenueCat(_ info : CSConst.csInitProduct)
    {
        initInfo = info

        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: initInfo.revenuecatApiKey)
        Purchases.shared.delegate = self
    }
    
    // get all avalible product
    
    private func getAllProduct(_ completion : @escaping ((_ err:CSConst.csError?) -> Void))
    {
        if allAvailableProduct.isEmpty
        {
            if CSNetConnection.shared.isConnected()
            {
                Purchases.shared.offerings { (offerings, error) in
                    
                    if let er = error
                    {
                        print("Log :- CSRevenueCat :- getAllProduct :- \(er.localizedDescription)")
                        completion(.unknown)
                        return
                    }
                    
                    if let packages = offerings?.current?.availablePackages
                    {
                        self.allAvailableProduct = packages
//                        print("Log :- CSRevenueCat :- getAllProduct :- Success :- \(packages.count)")
                        completion(nil)
                    }
                }
            }
            else
            {
                completion(.noInterNet)
            }
        }
        else
        {
            completion(nil)
        }
        
    }
}

// -------------------------------------------------
// MARK:- Get All Plane Info
// -------------------------------------------------

fileprivate extension CSRevenueCat
{
    // get single product info using tag
    func getProductInfo(_ planIndex : Int,
                        _ completion : @escaping ((_ productInfo:CSConst.csProductInfo?,
                                                   _ err:CSConst.csError?) -> Void))
    {
        getAllProduct
        {
            [self] (err) in
        
            if err != nil
            {
                completion(nil,err)
                return
            }
            
            let tempProductInfo = initInfo.allProduct[planIndex]
            let tempPriceInfo = getProductPrice(tempProductInfo.identifire)
            
            let tempPlanInfo = CSConst.csProductInfo(tag: tempProductInfo.tag,
                                                     identifire: tempProductInfo.identifire,
                                                     price_String: tempPriceInfo.price_string,
                                                     price: tempPriceInfo.price_Double,
                                                     currencyCode: tempPriceInfo.price_CurrencyCode,
                                                     freeTrail: getProductFreeTrail(tempProductInfo.identifire))
            
            
            completion(tempPlanInfo,err)
        }
    }
    
    private func getProductPrice(_ productID : String) -> (price_string:String,
                                                           price_Double:Double,
                                                           price_CurrencyCode:String)
    {
        let p1 =  allAvailableProduct.first
        {
            (p) -> Bool in
            return p.product.productIdentifier ==  productID
        }
        
        let tempStrPrice = p1?.localizedPriceString ?? "₹ 0.00"
        let tempDoublePrice = p1?.product.price as? Double ?? 0
        let tempCurrencyCode = p1?.product.priceLocale.currencySymbol ?? "₹"
        
        return (tempStrPrice,tempDoublePrice,tempCurrencyCode)
    }
    
    private func getProductFreeTrail(_ productID : String) -> CSConst.csProductFreeTrailInfo
    {
        let p1 =  allAvailableProduct.first
        {
            (p) -> Bool in
            
            return p.product.productIdentifier ==  productID
        }
        
        if let intOffer = p1?.product.introductoryPrice
        {
            let numberOfUnit = intOffer.subscriptionPeriod.numberOfUnits
            let unit = intOffer.subscriptionPeriod.unit
            
            return CSConst.csProductFreeTrailInfo(isEnabled: true,
                                                  duration: numberOfUnit,
                                                  unit: unit)
        }
        
        return CSConst.csProductFreeTrailInfo(isEnabled: false,
                                              duration: 0,
                                              unit: .day)
    }
    
}

// -------------------------------------------------
// MARK:- RevenueCat Delegate Method
// -------------------------------------------------
extension CSRevenueCat : PurchasesDelegate
{
    func purchases(_ purchases: Purchases, didReceiveUpdated purchaserInfo: Purchases.PurchaserInfo)
    {
        currentProductInfo = purchaserInfo
    }
}

// -------------------------------------------------
// MARK:- Purchase By RevenueCat
// -------------------------------------------------
fileprivate extension CSRevenueCat
{
    func purchaseByRC(_ product : CSConst.csProductInfo,
                      _ completion : @escaping ((CSConst.csError?) -> Void))
    {
        getAllProduct
        {
            [self] (err) in
            
            if err == nil
            {
                let p1 = allAvailableProduct.first
                {
                    (p) -> Bool in
                    return p.product.productIdentifier ==  product.identifire
                }
                
                if let prpForPurchase = p1
                {
                    Purchases.shared.purchasePackage(prpForPurchase)
                    {
                        (trans, info, error, cancelled) in
                        
                        if error != nil
                        {
                            completion(.purchaseFailed)
                        }
                        else
                        {
                            completion(nil)
                        }
                    }
                }
                else
                {
                    completion(.identifireNotFound)
                }
            }
            else
            {
                completion(err)
            }
        }
    }
}

// -------------------------------------------------
// MARK:- Restore By RevenueCat
// -------------------------------------------------
fileprivate extension CSRevenueCat
{
    func restoreByRC(_ completion : @escaping(_ error:CSConst.csError?)->Void)
    {
        Purchases.shared.restoreTransactions
        {
            [self] (tempPurchaseInfo, error) in
            
            if error != nil
            {
                print("Log :- CSRevenueCat :- restoreByRevenueCat :- \(error!.localizedDescription)")
                completion(.nothingForRestore)
            }
            else
            {
                currentProductInfo = tempPurchaseInfo
                
                if let activepurchases = tempPurchaseInfo?.entitlements.active,!activepurchases.isEmpty
                {
                    completion(nil)
                }
                
                completion(.nothingForRestore)
            }
        }
    }
}

// -------------------------------------------------
// MARK:- Get Old Purchases By RevenueCat
// -------------------------------------------------
fileprivate extension CSRevenueCat
{
    func syncPurchaseByRC(_ completion : @escaping ((_ err : CSConst.csError?) -> Void))
    {
        Purchases.shared.syncPurchases
        {
            [self](purchaserInfo, error) in
            
            if error != nil
            {
                print("Log :- CSRevenueCat :- syncOldPurchase :- \(error!.localizedDescription)")
                completion(.unknown)
                return
            }
            
            currentProductInfo = purchaserInfo!
            
            getLastPurchaseByRC { (err) in
                completion(err)
            }
        }
    }
    
    private func getLastPurchaseByRC(_ completion : @escaping ((_ err : CSConst.csError?) -> Void))
    {
        Purchases.shared.purchaserInfo
        {
            [self](purchaserInfo, error) in
            
            if error != nil
            {
                print("Log :- CSRevenueCat :- getLastPurchaseByRC :- \(error!.localizedDescription)")
                completion(.unknown)
                return
            }
            
            if purchaserInfo!.entitlements.active.isEmpty
            {
                completion(.lastPurchaseNotFound)
            }
            else
            {
                currentProductInfo = purchaserInfo!
                completion(nil)
            }

        }
    }
}













// ---------------------------------------------------------------------------------------------------------
// MARK:- interNetConnection Class
// ---------------------------------------------------------------------------------------------------------

fileprivate class CSNetConnection : NSObject
{
    // -------------------------------------------------
    // MARK:- All Varible's
    // -------------------------------------------------
    static var shared : CSNetConnection = CSNetConnection()
    
    // -------------------------------------------------
    // MARK:- All Function's
    // -------------------------------------------------
    func isConnected() -> Bool
    {
        let reachability : Reachability = try! Reachability()
    
        if reachability.connection == .unavailable
        {
            return false
        }
        
        return true
    }
}
