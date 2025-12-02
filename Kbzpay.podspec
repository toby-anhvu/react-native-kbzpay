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
    'DEFINES_MODULE' => 'YES',
    # Exclude arm64 for simulator to avoid architecture conflicts
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }

  # KBZPay Framework support
  s.preserve_paths = 'ios/Frameworks/KBZPayAPPPay.framework/**/*'
  
  # Include framework but link conditionally
  # Framework is always available (for archive builds) but only linked for device
  s.vendored_frameworks = 'ios/Frameworks/KBZPayAPPPay.framework'
  
  s.xcconfig = {
    'ENABLE_BITCODE' => 'NO',
    'FRAMEWORK_SEARCH_PATHS' => '$(inherited) "$(PODS_ROOT)/../../../ios/Frameworks"',
    # Strong link for device builds
    'OTHER_LDFLAGS[sdk=iphoneos*]' => '$(inherited) -framework "KBZPayAPPPay"',
    # Weak link for simulator (allows build but framework won't be used)
    'OTHER_LDFLAGS[sdk=iphonesimulator*]' => '$(inherited) -weak_framework "KBZPayAPPPay"'
  }

  install_modules_dependencies(s)
end
