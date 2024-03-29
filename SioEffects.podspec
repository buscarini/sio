Pod::Spec.new do |s|
  s.name         = "SioEffects"
  s.version      = "0.3.3"
  s.summary      = "Swift IO"
  s.description  = <<-DESC
    Swift Effects library. Console, fs, …
  DESC
  s.homepage     = "https://github.com/buscarini/sio"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "José Manuel Sánchez" => "buscarini@gmail.com" }
  s.social_media_url   = ""
  s.ios.deployment_target = "10.0"
  s.osx.deployment_target = "10.11"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "10.0"
  s.source       = { :git => "https://github.com/buscarini/sio.git", :tag => s.version.to_s }

  s.frameworks  = "Foundation"
  s.dependency 'Sio'
  s.dependency 'SioCodec'
  s.dependency 'SioValueStore'
  s.source_files  = "Sources/SioEffects/**/*"
  	
end
