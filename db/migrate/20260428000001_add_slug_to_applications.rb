class AddSlugToApplications < ActiveRecord::Migration[8.1]
  def up
    add_column :applications, :slug, :string

    Application.reset_column_information
    Application.find_each do |application|
      slug = (application.name.presence || application.key).to_s.parameterize
      application.update_columns(slug: slug) if slug.present?
    end

    add_index :applications, [:organization_id, :slug], unique: true
  end

  def down
    remove_index :applications, [:organization_id, :slug]
    remove_column :applications, :slug
  end
end
