#
# Be sure to run `pod lib lint MeshbluBeaconKit.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "MeshbluBeaconKit"
  s.version          = "0.1.0"
  s.summary          = "A short description of MeshbluBeaconKit."
  s.description      = <<-DESC
                       An optional longer description of MeshbluBeaconKit

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/octoblu/MeshbluBeaconKit"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Sqrt of Octoblu" => "sqrt@octoblu.com" }
  s.source           = { :git => "https://github.com/octoblu/MeshbluBeaconKit.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'MeshbluBeaconKit' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'CoreLocation'
  s.dependency 'MeshbluKit', '~> 0.1.0'
end
