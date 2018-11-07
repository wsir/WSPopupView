
Pod::Spec.new do |s|
  s.name             = 'WSPopupView'
  s.version          = '0.1.0'
  s.summary          = 'popupView.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/wsir/WSPopupView.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '351473007@qq.com' => 'wangsai@koolearn-inc.com' }
  s.source           = { :git => 'https://github.com/wsir/WSPopupView.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'WSPopupView/Classes/*'

end
