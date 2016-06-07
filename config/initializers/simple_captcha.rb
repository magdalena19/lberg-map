SimpleCaptcha.setup do |sc|
  sc.image_style = 'random'
  sc.distortion = 'medium'
  sc.implode = 'medium'
end

SimpleCaptcha.always_pass = Rails.env.test?
