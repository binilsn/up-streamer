class CreateServerChecks < ActiveRecord::Migration[8.1]
  def change
    create_table :server_checks do |t|
      t.references :service, null: false, foreign_key: true
      t.string :status, null: false
      t.integer :response_time_ms
      t.boolean :ssl_valid
      t.datetime :ssl_expires_at
      t.text :ssl_issuer
      t.datetime :checked_at, null: false
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :server_checks, [ :service_id, :checked_at ], name: "idx_server_checks_on_service_and_checked_at"
  end
end
