class AddUniqueIndexToUsersToken < ActiveRecord::Migration[8.1]
  # `token` was added to users without a backfill or an index, so rows created
  # before it existed carry NULL and every `User.find_by(token:)` is a full table
  # scan. Both matter now that the token authenticates API and MCP requests.
  #
  # A local model keeps this migration independent of app/models/user.rb, whose
  # validations and callbacks are free to change after this has shipped.
  class MigrationUser < ActiveRecord::Base
    self.table_name = "users"
  end

  def up
    backfill_missing_tokens
    resolve_duplicate_tokens

    add_index :users, :token, unique: true
  end

  def down
    remove_index :users, :token
  end

  private

  # has_secure_token only generates on create, so pre-existing rows never got one.
  def backfill_missing_tokens
    MigrationUser.where(token: nil).find_each do |user|
      user.update_columns(token: generate_token)
    end
  end

  # A base58(64) collision is not realistically possible, but the index is about to
  # become a constraint, and a migration that aborts midway through a deploy is a
  # worse outcome than regenerating a duplicate nobody has used yet. The oldest row
  # keeps its token; the rest are reissued.
  def resolve_duplicate_tokens
    duplicated = MigrationUser.group(:token).having("COUNT(*) > 1").pluck(:token).compact

    duplicated.each do |token|
      ids = MigrationUser.where(token: token).order(:id).pluck(:id).drop(1)

      MigrationUser.where(id: ids).find_each do |user|
        user.update_columns(token: generate_token)
      end
    end
  end

  # Matches `has_secure_token length: 64` in app/models/user.rb.
  def generate_token
    SecureRandom.base58(64)
  end
end
