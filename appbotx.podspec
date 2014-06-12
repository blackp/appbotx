#
# Be sure to run `pod lib lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = "AppbotX"
  s.version          = "0.1.0"
  s.summary          = "A short description of appbotx."
  s.description      = <<-DESC
                       An optional longer description of appbotx

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "http://appbot.co"
  s.license          = 'MIT'
  s.author           = { "Stuart Hall" => "stuartkhall@gmail.com" }
  s.source           = { :git => "http://github.com/appbotx/appbotx.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/stuartkhall'

  s.platform     = :ios, '6.0'
  s.requires_arc = true

  s.source_files  = 'Classes/*.{h,m}', 'Classes/Models/*.{h,m}', 'Classes/Views/*.{h,m}', 'Classes/Controllers/*.{h,m}', 'Classes/Classes/*.{h,m}'
end
