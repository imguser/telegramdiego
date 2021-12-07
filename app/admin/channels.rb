ActiveAdmin.register Channel do
  permit_params :name, :chat_id, :valid_sku

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :name, hint: "If supplied without a Chat ID, a new group will be created with this name."
      # f.input :username, hint: "Required if Chat ID is not provided."
      f.input :chat_id, label: 'Chat ID', hint: 'Supply if you would like to use an existing group'
      f.input :valid_sku, label: 'Valid SKU', input_html: { value: f.object.valid_sku.join(",") },
        hint: 'Comma-separated list of valid SKUs, e.g. 2,3,28,72,130,2000,5010', as: :string
    end
    f.actions
  end

  index do
    selectable_column
    id_column
    column "#id", :chat_id
    column :name
    # column :username
    column(:valid_sku) { |ch| ch.valid_sku.join(",")}
    column :invite_link
    column "#Users" do |ch|
      Telegram.bot.get_chat_members_count(chat_id: ch.chat_id) rescue 'N/A'
    end
    column :updated_at
    actions
  end

  # filter :channel_accesses # NOTE -> this may trigger memory issues
  # filter :regitered_users
  filter :chat
  filter :name
  filter :username
  filter :invite_link
  filter :valid_sku
  filter :created_at
  filter :updated_at

  show do |ch|
    attributes_table do
      row("#id") { ch.chat_id }
      row :name
      row :username
      row :invite_link
      row "#Users" do
        Telegram.bot.get_chat_members_count(chat_id: ch.chat_id) rescue 'N/A'
      end
      row(:valid_sku) { ch.valid_sku.join(", ")}
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end
end
