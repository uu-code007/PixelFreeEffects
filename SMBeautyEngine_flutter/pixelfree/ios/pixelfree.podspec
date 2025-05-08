#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint pixelfree.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'pixelfree'
  s.version          = '2.4.12'
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'
  
  # 添加 PixelFree.framework 依赖
  s.vendored_frameworks = 'pod/PixelFree.framework'
  
  # 添加资源文件
  s.resources = [
    'pod/res/filter_model.bundle',
    'pod/res/*.jpeg'
  ]
  
  # 确保资源文件被正确复制
  s.preserve_paths = [
    'pod/res/filter_model.bundle',
    'pod/res/*.jpeg'
  ]

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 
    'DEFINES_MODULE' => 'YES', 
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    'SWIFT_VERSION' => '5.0'
  }

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'pixelfree_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
