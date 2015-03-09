Pod::Spec.new do |s|

  s.name         = "MCCardPickerCollectionViewController"
  s.version      = "1.0.0"
  s.summary      = "A card collection view controller inspired by Facebook People you may know."

  s.description  = <<-DESC
                   A card collection view controller inspired by Facebook People you may know.

                   - Required on iOS 7.
                   - Use it as normal collection view controller.
                   DESC

  s.homepage     = "https://github.com/yuhua-chen/MCCardPickerCollectionViewController"
  s.screenshots  = "https://s3.amazonaws.com/cocoacontrols_production/uploads/control_image/image/5856/iOS_Simulator_Screen_Shot_2015_3_4____5.11.02.png"

  s.license      = "MIT"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Michael Chen" => "michaelchen@kkbox.com" }
  s.social_media_url   = "http://twitter.com/yuhua_twit"

  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/yuhua-chen/MCCardPickerCollectionViewController.git", :tag => s.version.to_s }
  
  s.source_files  = "MCCardPickerCollectionViewController/Classes"
  s.exclude_files = "Classes/Exclude"

  s.requires_arc = true
  s.frameworks = 'Foundation', 'UIKit'

end
