Pod::Spec.new do |s|
  s.name             = "MeshbluBeaconKit"
  s.version          = "2.7.0"
  s.summary          = "Easily connection iBeacons to Meshblu"
  s.description      = <<-DESC
		       Handles all the complexity of ranging iBeacons and connecting them to Meshblu
                       DESC
  s.homepage         = "https://github.com/octoblu/MeshbluBeaconKit"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Octoblu" => "cocoapods@octoblu.com" }
  s.source           = { :git => "https://github.com/octoblu/MeshbluBeaconKit.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/octoblu'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'MeshbluBeaconKit/Classes/**/*'
  s.frameworks = 'CoreLocation'
  s.dependency 'MeshbluHttp', '~> 1.1'
  s.dependency 'Dollar', '~> 5.2'
  s.dependency 'Result', '~> 2.1'
end
