#
# Be sure to run `pod lib lint YXYPlayer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'YXYPlayer'
  s.version          = '0.0.2'
  s.summary          = '一个基于AVPlayer深度可定制化的iOS播放器'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = '一个基于AVPlayer深度可定制化的iOS播放器'

  s.homepage         = 'https://github.com/YXYCareFree/YXYPlayer'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'YXYCareFree' => '576842121@qq.com' }
  s.source           = { :git => 'https://github.com/YXYCareFree/YXYPlayer.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'YXYPlayer/Classes/**/*'
  
  # s.resource_bundles = {
  #   'YXYPlayer' => ['YXYPlayer/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
   s.dependency 'YXYBaseViewController'
end
