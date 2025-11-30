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
  
  # Conditionally link framework only for device builds (not simulator)
  # The framework only supports device architectures, not simulator
  s.xcconfig = {
    'ENABLE_BITCODE' => 'NO',
    # Framework linking is conditional - only for device builds
    'OTHER_LDFLAGS[sdk=iphoneos*]' => '$(inherited) -framework "KBZPayAPPPay"',
    'FRAMEWORK_SEARCH_PATHS[sdk=iphoneos*]' => '$(inherited) "$(PODS_ROOT)/../../../ios/Frameworks"'
  }
  
  # Note: vendored_frameworks is removed to allow conditional linking
  # The framework will only be linked for device builds via xcconfig

  install_modules_dependencies(s)
end
