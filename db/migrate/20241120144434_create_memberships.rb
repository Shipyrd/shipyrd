class CreateMemberships < ActiveRecord::Migration[7.2]
  def change
    create_table :memberships do |t|
      t.references :user, null: false, foreign_key: true, type: :bigint
      t.references :organization, null: false, foreign_key: true, type: :bigint

      t.timestamps
    end
  end
end
