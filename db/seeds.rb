seed_file = "#{Rails.root}/db/seeds.#{Rails.env}.rb"
load "#{Rails.root}/db/seeds.#{Rails.env}.rb" if File.exists?(seed_file)
