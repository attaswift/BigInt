
Pod::Spec.new do |spec|
    spec.name         = 'BigInt'
    spec.version      = '5.3.0'
    spec.ios.deployment_target = "12.0"
    spec.osx.deployment_target = "10.15"
    spec.tvos.deployment_target = "12.0"
    spec.watchos.deployment_target = "4.0"
    spec.license      = { :type => 'MIT', :file => 'LICENSE.md' }
    spec.summary      = 'Arbitrary-precision arithmetic in pure Swift'
    spec.homepage     = 'https://github.com/attaswift/BigInt'
    spec.author       = 'Károly Lőrentey'
    spec.source       = { :git => 'https://github.com/attaswift/BigInt.git', :tag => 'v' + String(spec.version) }
    spec.source_files = 'Sources/*.swift'
    spec.social_media_url = 'https://twitter.com/lorentey'
    spec.documentation_url = 'http://attaswift.github.io/BigInt/'
    spec.swift_version = '5.5'
end
