Pod::Spec.new do |s|

  s.name                  = "TouchDraw"
  s.version               = "1.1.0"
  s.summary               = "TouchDraw is a UIView you can draw on."

  s.description           = <<-DESC
                            TouchDraw is a subclass of UIView that allows you to draw using touch. It exposes the following functions:
                            - `exportDrawing() -> UIImage`
                            - `clearDrawing()`
                            - `setColor(color: UIColor)`
                            - `setWidth(width: CGFloat)`
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
