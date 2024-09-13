class RunnerJob < ApplicationJob
  def perform(id)
    Runner.find(id).run!
  end
end
