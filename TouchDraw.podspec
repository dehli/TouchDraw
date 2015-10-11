Pod::Spec.new do |s|

  s.name                  = "TouchDraw"
  s.version               = "0.0.1"
  s.summary               = "TouchDraw lets you can draw with your finger."

  s.description           = <<-DESC
                            TouchDraw is a subclass of UIView that allows you to draw on a UIView.
                            DESC

  s.homepage              = "https://github.com/dehli/TouchDraw"
  # s.screenshots           = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"

  s.license               = { :type => "MIT", :file => "LICENSE" }

  s.author                = { "Christian Paul Dehli" => "dehli@gatech.edu" }
  s.social_media_url      = "http://twitter.com/cpdehli"

  s.platform              = :ios
  s.ios.deployment_target = "8.0"

  s.source                = { :git => "https://github.com/dehli/TouchDraw.git", :tag => "#{s.version}"}
  s.source_files          = "TouchDraw/**/*.{swift}"

end
