class Runner < ApplicationRecord
  belongs_to :destination

  # after_create_commit :start_runner

  def display_command
    "kamal #{command}"
  end

  def start_runner
    update(started_at: Time.current)

    output, error = "", ""

    destination.with_recipe do |base_recipe_path|
      update(
        full_command: "kamal #{command} #{cli_options(base_recipe_path)}"
      )

      cmd.run(full_command) do |out, err|
        update(output: output += out) if out
        update(error: error += err) if err
      end
    end
  rescue TTY::Command::ExitError => e
    Rails.logger.info "Runner failed with #{e}"
  ensure
    update(finished_at: Time.current)
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
    TTY::Command.new(printer: Rails.env.local? ? :pretty : :null)
  end
end
