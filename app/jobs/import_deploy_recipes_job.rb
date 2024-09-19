class ImportDeployRecipesJob < ApplicationJob
  def perform(id)
    Connection.find(id).import_deploy_recipes
  end
end
