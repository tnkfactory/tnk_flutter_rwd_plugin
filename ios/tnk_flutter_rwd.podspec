#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint tnk_flutter_rwd.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'tnk_flutter_rwd'
  s.version          = '0.0.1'
  s.summary          = 'tnkfactory rwd sdk for flutter'
  s.description      = <<-DESC
tnkfactory rwd sdk for flutter
                       DESC
  s.homepage         = 'https://github.com/tnkfactory/tnk_flutter_rwd_plugin'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'tnkfactory' => 'platform@tnkfactory.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'

  # Flutter.framework does not contain a i386 slice.
    s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
    s.swift_version = '5.0'
  #   s.preserve_paths = 'TnkRwdSdk.xcframework/**/*'
    s.preserve_paths = 'TnkRwdSdk.xcframework/**/*'
      s.xcconfig = { 'OTHER_LDFLAGS' => '-framework TnkRwdSdk' }
      s.vendored_frameworks = 'TnkRwdSdk.xcframework'
end
