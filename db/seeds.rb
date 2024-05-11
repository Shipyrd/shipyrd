seed_file = "#{Rails.root.join("db/seeds.#{Rails.env}.rb")}"
load "#{Rails.root.join("db/seeds.#{Rails.env}.rb")}" if File.exist?(seed_file)
