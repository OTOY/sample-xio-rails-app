class CreateFileProviderCredentials < ActiveRecord::Migration
  def change
    create_table :file_provider_credentials do |t|
      t.integer  :user_id
      t.string   :type
      t.string   :label
      t.datetime :expires_at
      t.string   :provider_account_name
      t.text     :provider_account_details
      t.text     :provider_credentials

      t.timestamps
    end

    add_index :file_provider_credentials, :user_id
    add_index :file_provider_credentials, :type
  end
end
