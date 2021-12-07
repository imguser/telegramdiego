class CreateGlobalSnippets < ActiveRecord::Migration[5.2]
  def change
    create_table :global_snippets do |t|
      t.string :name, index: true, unique: true
      t.string :value
      t.boolean :is_example, default: false

      t.timestamps
    end
  end
end
