Pod::Spec.new do |s|
  s.name             = 'in_app_browser'
  s.version          = '0.0.1'
  s.summary          = 'A lightweight in-app browser for Flutter'
  s.description      = <<-DESC
A native-feeling, Instagram-style browser experience with smooth animations, gesture controls, and modern UI.
                       DESC
  s.homepage         = 'https://github.com/KANAGARAJ-M/in_app_browser'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'
  s.swift_version = '5.0'
end