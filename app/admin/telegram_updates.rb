ActiveAdmin.register TelegramUpdate do
  actions :index, :show, :destroy
  before_action :skip_sidebar!

  controller do
    before_action :delete_old_telegram_updates, only: :index

    private

    def delete_old_telegram_updates
      TelegramUpdate.where('created_at < ?', 7.days.ago).delete_all
    end
  end

  scope :all
  scope :failed, default: true
  scope :pending
  scope :successful

  index do
    selectable_column
    id_column
    column '#id', :update_id
    column :content
    column :content_type
    column('Pending?', :pending)
    column('Successful?', :success)
    column(:response){|u| "<pre>#{u.response}</pre>".html_safe}
    column :updated_at
  end

  show do |u|
    attributes_table do
      row('#id'){ u.update_id }
      row :content
      row :content_type
      row('Pending?'){ u.pending? }
      row('Successful?'){ u.success? }
      row :created_at
      row :updated_at
      row(:response){"<pre>#{u.response}</pre>".html_safe} unless u.pending?
      row(:error_class) if u.failed?
      row(:error_message) if u.failed?
      row(:error_backtrace){ "<pre>#{u.error_backtrace}</pre>".html_safe } if u.failed?
      row(:payload){ "<pre><code>#{JSON.pretty_generate(u.payload)}</code></pre>".html_safe }
    end
    active_admin_comments
  end
end
