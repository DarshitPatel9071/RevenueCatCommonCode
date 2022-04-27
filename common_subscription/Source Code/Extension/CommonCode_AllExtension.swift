//
//  CommonCode_AllExtension.swift
//  Common_Subscripton_Code
//
//  Created by iOS on 30/03/22.
//

import Foundation
import UIKit
import MBProgressHUD     

internal extension UIViewController
{
    func CS_startLoader()
    {
        MBProgressHUD.showAdded(to: view, animated: true)
    }
    
    func CS_stopLoader()
    {
        MBProgressHUD.hide(for: view, animated: true)
    }
    
    func CSShowErrorAlert(_ title: String = "Error",
                          _ message : String,
                          _ btnTitle : String = "OK",
                          _ completion : (() -> Void)? = nil)
    {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: btnTitle,
                                      style: .cancel, handler: { (alert) in
                                        
                                        completion?()
                                        
                                      }))
        
        DispatchQueue.main.async
        {
            self.present(alert, animated: true, completion: nil)
        }
    }
}

internal extension UIApplication
{
    class func CSGetTopVC(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController?
    {
        if let nav = base as? UINavigationController
        {
            return CSGetTopVC(base: nav.visibleViewController)
        }
        else if let tab = base as? UITabBarController, let selected = tab.selectedViewController
        {
            return CSGetTopVC(base: selected)
        }
        else if let presented = base?.presentedViewController
        {
            return CSGetTopVC(base: presented)
        }
        
        return base
    }
}
