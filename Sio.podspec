Pod::Spec.new do |s|
  s.name         = "Sio"
  s.version      = "0.1"
  s.summary      = "Swift IO"
  s.description  = <<-DESC
    Swift Effects library, ala ZIO.
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
  
  s.subspec 'Core' do |cs|
    cs.source_files  = "Sources/Sio/**/*"
  end
  
  s.subspec 'SioCodec' do |cs|
    cs.dependency 'Core'
    cs.source_files  = "Sources/SioCodec/**/*"
  end
	
  s.subspec 'SioEffects' do |cs|
    cs.dependency 'Core'
    cs.source_files  = "Sources/SioEffects/**/*"
  end
	
  s.subspec 'SioValueStore' do |cs|
    cs.dependency 'Core'
    cs.dependency 'SioCodec'
    cs.source_files  = "Sources/SioValueStore/**/*"
  end
	
end