Pod::Spec.new do |s|
  s.name             = 'Pailead'
  s.version          = '1.0.0'
  s.summary          = 'Extract a color palette from an image'

  s.description      = <<-DESC
Extract average colors from an image just like Googles Palette library on Android. Written to be a fast way to show vibrant colors behind or before an image.
                       DESC

  s.homepage         = 'https://github.com/pducks32/Pailead'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'pducks32' => 'git@patrickmetcalfe.com' }
  s.source           = { :git => 'https://github.com/pducks32/Pailead.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/pducks32'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.12'

  s.source_files = 'Sources/Pailead/**/*'
end
