require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "Kbzpay"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platforms    = { :ios => min_ios_version_supported }
  s.source       = { :git => "https://github.com/toby-anhvu/react-native-kbzpay.git", :tag => "#{s.version}" }

  s.source_files = "ios/*.{h,m,mm,swift}"
  
  # Swift support
  s.swift_version = '5.0'
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES'
  }

  # KBZPay Framework support
  s.preserve_paths = 'ios/Frameworks/KBZPayAPPPay.framework/**/*'
  
  s.xcconfig = {
    'OTHER_LDFLAGS' => '-framework KBZPayAPPPay',
    'ENABLE_BITCODE' => 'NO',
    'FRAMEWORK_SEARCH_PATHS' => '"$(PODS_ROOT)/../../../ios/Frameworks"'
  }
  
  # KBZPay framework is included
  s.vendored_frameworks = 'ios/Frameworks/KBZPayAPPPay.framework'

  install_modules_dependencies(s)
end
