class CreateAlerts < ActiveRecord::Migration[8.1]
  def change
    create_table :alerts do |t|
      t.references :alert_rule, null: false, foreign_key: true
      t.references :log, foreign_key: true, null: true
      t.references :service, foreign_key: true, null: true
      t.string :title, null: false
      t.text :description
      t.string :severity, null: false, default: "medium"
      t.string :status, null: false, default: "active"
      t.datetime :triggered_at, null: false
      t.datetime :resolved_at
      t.jsonb :metadata
      t.timestamps
    end

    add_index :alerts, :status
    add_index :alerts, :severity
    add_index :alerts, :triggered_at
    add_index :alerts, [ :alert_rule_id, :status ]
  end
end
