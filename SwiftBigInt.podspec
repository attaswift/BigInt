Pod::Spec.new do |s|
  s.name         = "SwiftBigInt"
  s.version      = "6.0.1"
  s.summary      = "Arbitrary-precision arithmetic in pure Swift"
  s.description  = <<-DESC
    This library provides arbitrary-precision integer arithmetic using pure Swift.
    It defines two integer types: BigUInt for unsigned integers, and BigInt for 
    signed integers. Both types have the full set of operations supported by Swift's 
    standard integer types, plus more complicated arithmetic operations like division, 
    exponentiation, modulo, GCD, square root, primality testing, and more.
  DESC

  s.homepage     = "https://github.com/jlalvarez18/BigInt"
  s.license      = { :type => "MIT", :file => "LICENSE.md" }
  s.author       = { "Károly Lőrentey" => "karoly@lorentey.hu" }
  
  s.swift_version = "5.9"
  
  # Platform support matching Package.swift
  s.ios.deployment_target = "12.0"
  s.osx.deployment_target = "10.13"
  
  s.source       = { :git => "https://github.com/jlalvarez18/BigInt.git", :tag => "v#{s.version}" }
  s.source_files = "Sources/**/*.swift"
  
  s.module_name  = "SwiftBigInt"
  s.requires_arc = true
  
  # Enable strict concurrency as specified in Package.swift
  s.pod_target_xcconfig = {
    'SWIFT_STRICT_CONCURRENCY' => 'complete'
  }
  
  s.frameworks = "Foundation"
  
  # Test spec
  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Tests/**/*.swift'
    test_spec.pod_target_xcconfig = {
      'SWIFT_STRICT_CONCURRENCY' => 'complete'
    }
  end
end
