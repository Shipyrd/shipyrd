class AllowNullOauthTokenApplication < ActiveRecord::Migration[8.1]
  def change
    change_column_null :oauth_tokens, :application_id, true
  end
end
