platform :ios, '10.0'
use_frameworks!

target 'weather_ios' do
    pod 'RxSwift', '~> 3.0'
    pod 'RxCocoa', '~> 3.0'
    pod 'RxNuke'
    pod 'Moya/RxSwift'
end

target 'weather_iosTests' do
    use_frameworks!

    pod 'RxCocoa', '~> 3.0'
    pod 'RxBlocking', '~> 3.0'
    pod 'RxTest', '~> 3.0'
	pod 'Quick'
    pod 'Nimble', '~> 7.0.1'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
