class CreateLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :logs do |t|
      t.references :service, null: false, foreign_key: true
      t.string :level
      t.text :message
      t.string :hostname
      t.string :error_code
      t.datetime :timestamp, null: false
      t.jsonb :metadata

      t.timestamps
    end
  end
end
