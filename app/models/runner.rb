class Runner < ApplicationRecord
  belongs_to :destination

  after_create_commit :queue_run

  broadcasts

  def display_command
    "kamal #{command}"
  end

  def queue_run
    RunnerJob.perform_later(id)
  end

  def run!
    update(started_at: Time.current)

    output, error = "", ""

    destination.with_recipe do |base_recipe_path|
      update(
        full_command: "kamal #{command} #{cli_options(base_recipe_path)}"
      )

      cmd.run(*full_command.split(" ")) do |out, err|
        update(output: output += out.force_encoding("UTF-8")) if out
        update(error: error += err.force_encoding("UTF-8")) if err
      end
    end
  rescue TTY::Command::ExitError => e
    Rails.logger.info "Runner failed with #{e}"
    update(error: e)
  ensure
    update(finished_at: Time.current)
  end

  def finished?
    finished_at.present?
  end

  def cli_options(base_recipe_path)
    [
      destination.default? ? nil : "--destination #{destination.name}",
      "--config-file #{base_recipe_path}/deploy.yml"
    ].compact.join(" ")
  end

  def time
    return nil unless started_at.present? && finished_at.present?

    (finished_at - started_at).to_i
  end

  def cmd
    TTY::Command.new(printer: :null)
  end
end
