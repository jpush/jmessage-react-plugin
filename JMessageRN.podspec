require 'json'
pjson = JSON.parse(File.read('package.json'))

Pod::Spec.new do |s|

  s.name            = "JMessageRN"
  s.version         = pjson["version"]
  s.homepage        = "https://github.com/jpush/jmessage-react-native"
  s.summary         = pjson["description"]
  s.license         = pjson["license"]
  s.author          = { "ys" => "ysyates@163.com" }
  
  s.ios.deployment_target = '7.0'

  s.source          = { :git => "https://github.com/jpush/jmessage-react-native.git", :tag => "#{s.version}" }
  s.source_files    = 'ios/RCTJMessageModule/*.{h,m}'
  s.preserve_paths  = "*.js"
  s.frameworks      = 'UIKit','CFNetwork','CoreFoundation','CoreTelephony','SystemConfiguration','CoreGraphics','Foundation','Security','CoreLocation','CoreAudio','AudioToolbox','AVFoundation'
  s.weak_frameworks = 'UserNotifications'
  s.libraries       = 'z','resolv','sqlite3.0'
  s.vendored_libraries = "ios/RCTJMessageModule/*.a"
  s.vendored_frameworks = "ios/RCTJMessageModule/JMessage.framework"
  s.dependency 'React'
end
