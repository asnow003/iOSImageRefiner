Pod::Spec.new do |s|
  s.name             = 'iOSImageRefiner'
  s.version          = '1.1.0'
  s.summary          = 'iOS viewcontroller for cropping and resizing images......'
 
  s.description      = <<-DESC
  iOS viewcontroller that can be added to your existing application so that users can refine their images that are selected.
                       DESC
 
  s.homepage         = 'https://github.com/asnow003/iOSImageRefiner'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Allen Snow' => 'asnow@allensnow.com' }
  s.source           = { :git => 'https://github.com/asnow003/iOSImageRefiner.git', :tag => s.version.to_s }
 
  s.ios.deployment_target = '11.3'
  s.swift_version = '4.1'
  s.source_files = [
    'iOSImageRefiner/ImageRefiner/ImageRefinerOptions.swift',
    'iOSImageRefiner/ImageRefiner/ImageRefinerOptionsViewController.swift',
    'iOSImageRefiner/ImageRefiner/ImageRefinerViewController.swift'
  ]
  s.resources = [
    'iOSImageRefiner/ImageRefiner/ImageRefiner.storyboard',
     'iOSImageRefiner/ImageRefiner/ImageRefiner.xcassets'
    ]
end