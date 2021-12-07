ActiveAdmin.register MessageReply do
  permit_params :quote_message, :use_markdown, :content, :related_link
  actions :all, except: [:new, :create, :show, :destroy]

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :name, input_html: { disabled: f.object.system_required? }

      f.input :content, as: :text, input_html: { rows: 5 },
        hint: "Example reply:<br/><p class='inline-hints'>#{f.object.parsed_html_content}</p>".html_safe
      f.input :quote_message, label: 'Quote message?'
      f.input :private, label: 'Reply privately to the user?'
      f.input :use_markdown, label: 'Parse reply as Markdown formatted?'

      f.input :related_link

      f.input :snippets, as: :text,
        input_html: { rows: 5, disabled: f.object.system_required? },
        hint: 'This is an example of what snippets are available. Values will change based on Message received in Telegram.'
    end
    f.actions
  end

  index do
    # selectable_column
    # id_column
    column(:name){|mr| link_to mr.name, edit_message_reply_path(mr)}
    column :content
    column :related_link
    column :help
  end
end
