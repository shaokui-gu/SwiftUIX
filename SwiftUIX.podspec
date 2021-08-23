Pod::Spec.new do |s|
  s.name     = 'SwiftUIX'
  s.version  = '0.1'
  s.license  = 'MIT'
  s.platform = :ios, "13.0"
  s.summary  = 'The SwiftUIX Components set'
  s.homepage = 'https://github.com/shaokui-gu/SwiftUIX'
  s.description  = <<-DESC
                    HBimsab 是 HBimsab程序打包的sdk项目，外部可以直接引用
                   DESC
  s.author       = { 'gsk' => 'gushaokui@126.com' }
  s.source       = { :git => "https://github.com/shaokui-gu/SwiftUIX.git", :tag => s.version.to_s }
  s.source_files = 'Sources/*'
  s.ios.deployment_target = '13.0'
end


