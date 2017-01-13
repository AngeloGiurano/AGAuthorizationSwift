# Uncomment this line to define a global platform for your project
# platform :ios, '8.0'
# Uncomment this line if you're using Swift
use_frameworks!

target ‘Authorization’ do
    pod 'Alamofire'
    pod 'AlamofireObjectMapper', :git => 'https://github.com/tristanhimmelman/AlamofireObjectMapper.git', :branch => 'swift-3'
    pod 'KeychainAccess', '~> 3.0'
    pod 'PromiseKit', :git => 'https://github.com/mxcl/PromiseKit.git', :branch => 'swift-3.0'
    pod 'DateTools'
    #pod 'OAuthSwift', '~> 0.5.0'
    #pod 'ReachabilitySwift', :git => 'https://github.com/ashleymills/Reachability.swift'
    #, :git => 'https://github.com/mxcl/PromiseKit.git', :branch => 'swift-2.0-beta5'
end

target ‘AuthorizationTests’ do
    pod 'Alamofire'
    pod 'AlamofireObjectMapper', :git => 'https://github.com/tristanhimmelman/AlamofireObjectMapper.git', :branch => 'swift-3'
    pod 'KeychainAccess', '~> 3.0'
    pod 'PromiseKit', :git => 'https://github.com/mxcl/PromiseKit.git', :branch => 'swift-3.0'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
