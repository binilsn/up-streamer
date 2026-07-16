class CreateAlertRules < ActiveRecord::Migration[8.1]
  def change
    create_table :alert_rules do |t|
      t.string :name, null: false
      t.text :description
      t.references :service, foreign_key: true, null: true
      t.string :level
      t.string :field, null: false
      t.string :operator, null: false, default: "eq"
      t.string :value, null: false
      t.string :severity, null: false, default: "medium"
      t.boolean :enabled, null: false, default: true
      t.integer :cooldown_minutes, null: false, default: 5
      t.datetime :last_triggered_at
      t.timestamps
    end

    add_index :alert_rules, :enabled
    add_index :alert_rules, :level
    add_index :alert_rules, :field
  end
end
