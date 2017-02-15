# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

target 'tassarim' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  pod 'Alamofire', '~> 4.3'
  pod 'SwiftyJSON'
pod 'Spring', :git => 'https://github.com/MengTo/Spring.git', :branch => 'swift3'
pod 'UIColor_Hex_Swift', '~> 3.0.2'
  # pod 'PullToRefresher'
  pod 'NVActivityIndicatorView'
  pod 'Gifu'
pod 'BTNavigationDropdownMenu', :git => 'https://github.com/PhamBaTho/BTNavigationDropdownMenu.git', :branch => 'swift-3.0'
  pod 'Fabric'
  pod 'Crashlytics'
  #pod 'PageMenu'
  pod 'OAuthSwift', '~> 1.1.0'
  #pod 'KeychainAccess' 'https://github.com/kishikawakatsumi/KeychainAccess/KeychainAccess.git' :branch => 'swift2.3'
  #pod "MXParallaxHeader"
pod 'Haneke', '~> 1.0'
  #pod 'HanekeSwift'
  pod 'SDWebImage'
  #pod 'GoogleAnalytics'
  pod 'Google/Analytics'
  pod 'RandomColorSwift'
  pod 'ChameleonFramework/Swift'
  pod 'KeychainAccess'


  target 'tassarimTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'tassarimUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
