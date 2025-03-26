Pod::Spec.new do |s|
  s.name = 'gr4vy-ios'
  s.version = '2.5.0'
  s.license = 'MIT'
  s.summary = 'Quickly embed Gr4vy in your iOS app to store card details, authorize payments, and capture a transaction.'
  s.homepage = 'https://github.com/gr4vy/gr4vy-ios'
  s.authors = { 'Gr4vy' => 'mobile@gr4vy.com' }
  s.source = { :git => 'https://github.com/gr4vy/gr4vy-ios.git', :tag => s.version }
  s.documentation_url = 'https://github.com/gr4vy/gr4vy-ios'

  s.ios.deployment_target = '14.0'

  s.swift_versions = ['5.3', '5.4', '5.5']
  s.source_files = 'gr4vy-iOS/**/*.swift'
  s.resource_bundles = { 'gr4vy-ios-Assets' => ['gr4vy-iOS/*.xcassets'] }
end