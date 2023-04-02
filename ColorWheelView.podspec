Pod::Spec.new do |s|
  s.name         = 'ColorWheelView'
  s.version      = '1.0.0'
  s.summary      = 'Color picker wheel view.'
  s.homepage     = 'https://github.com/rnkyr/ColorWheelView'
  s.license      = { type: 'MIT', file: 'License' }
  s.authors      = { 'Roman Kyrylenko': 'roma.kyrylenko@gmail.com' }
  s.source       = { git: 'https://github.com/rnkyr/APIClient.git', tag: s.version }
  s.frameworks   = 'Foundation'
  s.ios.deployment_target = '13.0'
  s.source_files = 'ColorWheel/*.swift'
  s.resources = "ColorWheel/*.xcassets"
end
