
Pod::Spec.new do |spec|
    spec.name         = 'BigInt'
    spec.version      = '2.1.0'
    spec.osx.deployment_target = "10.9"
    spec.ios.deployment_target = "8.0"
    spec.tvos.deployment_target = "9.0"
    spec.watchos.deployment_target = "2.0"
    spec.license      = { :type => 'MIT', :file => 'LICENSE.md' }
    spec.summary      = 'Arbitrary-precision arithmetic in pure Swift'
    spec.homepage     = 'https://github.com/lorentey/BigInt'
    spec.author       = 'Károly Lőrentey'
    spec.source       = { :git => 'https://github.com/lorentey/BigInt.git', :tag => 'v2.1.0' }
    spec.source_files = 'Sources/*.swift'
    spec.social_media_url = 'https://twitter.com/lorentey'
    spec.documentation_url = 'http://lorentey.github.io/BigInt/api/'
end
