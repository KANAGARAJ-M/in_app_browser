Pod::Spec.new do |s|
  s.name             = 'flutter_in_app_browser'
  s.version          = '0.0.1'
  s.summary          = 'A lightweight, customizable in-app browser for Flutter'
  s.description      = <<-DESC
A lightweight, customizable in-app browser for Flutter. This package provides a native-feeling, Instagram-style browser experience with smooth animations, gesture controls, and a modern UI.
                       DESC
  s.homepage         = 'https://github.com/KANAGARAJ-M/in_app_browser'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'KANAGARAJ M' => 'kanagaraj.mark@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'
  s.swift_version = '5.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end