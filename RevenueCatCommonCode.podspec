Pod::Spec.new do |spec|

  spec.name         = "RevenueCatCommonCode"
  spec.version      = "1.0.0"
  spec.summary      = "Common RevenueCat code"
  spec.description  = <<-DESC
  this pod helps you for use common RevenueCat code in your peoject.
                   DESC
  spec.homepage     = "https://github.com/DarshitPatel9071/RevenueCatCommonCode"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Darshit Patel" => "" }
  spec.source       = { :git => "https://github.com/DarshitPatel9071/RevenueCatCommonCode.git", :tag => "#{spec.version}" }
  spec.source_files  = 'common_subscription/**/*.{swift}'
  spec.ios.deployment_target = '12.0'
  spec.swift_versions = "5.0"
  spec.dependency 'Purchases'
  spec.dependency 'ReachabilitySwift'
  spec.dependency 'MBProgressHUD'
  spec.static_framework = true
end
