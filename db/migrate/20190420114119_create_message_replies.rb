class CreateMessageReplies < ActiveRecord::Migration[5.2]
  def change
    create_table :message_replies do |t|
      t.string :name, unique: true, index: true
      t.text :content
      t.text :help
      t.string :related_link
      t.jsonb :available_snippets, default: {}
      t.boolean :quote_message, default: false
      t.boolean :use_markdown, default: false
      t.boolean :system_required, default: true

      t.timestamps
    end
  end
end
