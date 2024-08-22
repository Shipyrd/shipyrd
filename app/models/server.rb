class Server < ApplicationRecord
  belongs_to :destination

  broadcasts

  # def cli_options
  #   name.present? ? "--destination #{name}" : nil
  # end

  # TODO
  # def run_cli_command
  #   destination.with_recipe do |base_recipe_path|
  #     output = `kamal lock status -d production -c #{base_recipe_path}`
  #   end
  # end
end
