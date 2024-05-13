seed_file = Rails.root.join("db/seeds.#{Rails.env}.rb").to_s
load Rails.root.join("db/seeds.#{Rails.env}.rb").to_s if File.exist?(seed_file)
