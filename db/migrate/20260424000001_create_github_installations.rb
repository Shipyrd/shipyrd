class CreateGithubInstallations < ActiveRecord::Migration[8.1]
  def up
    create_table :github_installations do |t|
      t.references :application, null: false, foreign_key: true, index: {unique: true}
      t.bigint :installation_id, null: false
      t.timestamps
    end
    add_index :github_installations, :installation_id

    Application.reset_column_information
    GithubInstallation.skip_callback(:create, :after, :create_channel)

    Application.where.not(github_installation_id: nil).find_each do |app|
      github_installation = GithubInstallation.create!(
        application: app,
        installation_id: app.github_installation_id
      )

      existing = app.channels.where(channel_type: Channel.channel_types[:github], owner_id: nil).first

      if existing
        existing.update_columns(
          owner_type: "GithubInstallation",
          owner_id: github_installation.id,
          updated_at: Time.current
        )
      else
        github_installation.send(:create_channel)
      end
    end

    GithubInstallation.set_callback(:create, :after, :create_channel)

    remove_column :applications, :github_installation_id
  end

  def down
    add_column :applications, :github_installation_id, :bigint

    GithubInstallation.find_each do |gi|
      gi.application.update_column(:github_installation_id, gi.installation_id)
    end

    drop_table :github_installations
  end
end
