ActiveAdmin.register RegisteredUser do
  actions :all, except: [:new, :create]
  permit_params :external_id, :provided_email, :verified

  scope :all, default: true
  scope :verified
  scope :unverified

  action_item :syncrhonize, only: :show do
    link_to "Synchronize SKU", sync_registered_user_path
  end

  member_action :sync, method: :get do
    user = resource
    user.update_sku()
    user.update_channel_access()
    redirect_to request.referer || resource_path, notice: "User was syncronized!"
  end

  batch_action :ban do |ids, options|
    # get filtered channle id 
    channel_id = request.query_parameters.fetch(:q, {})[:active_channels_access_channel_id_eq]
    
    batch_action_collection.find(ids).each do | user |
      if channel_id
        user.ban_channel(channel_id)
      else
        user.ban_all_channels()
      end

    end
    redirect_to request.referer, alert: "The users were banned"
  end

  batch_action :sync do |ids, options|
    batch_action_collection.find(ids).each do | user |
        user.update_sku()
        user.update_channel_access()
    end
    redirect_to request.referer, alert: "The users were syncronized!"
  end

  index do
    selectable_column
    id_column
    column :first_name
    column :last_name
    column 'TG Username', :username
    column 'TG ID', :telegram_id
    column 'ExternalID', :external_id
    column :verified
    column 'SKU synchronized at', :sku_synchronized_at
    actions
  end

  filter :active_channels
  filter :telegram_id
  filter :external_id
  filter :first_name
  filter :last_name
  filter :username
  filter :verified
  filter :provided_email
  filter :created_at
  filter :updated_at

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :first_name, input_html: { disabled: true }
      f.input :last_name, input_html: { disabled: true }
      f.input :username, input_html: { disabled: true }
      f.input :telegram_id, input_html: { disabled: true }
      f.input :language_code, input_html: { disabled: true }
      f.input :verified
      f.input :external_id
      f.input :provided_email
    end
    f.actions
  end

  show do |ru|
    attributes_table do
      row :id
      row('External ID') { ru.external_id }
      row('Telegram ID') { ru.telegram_id }
      row :username
      row :access_hash
      row :first_name
      row :last_name
      row :language_code
      row :provided_email
      row('External data') { ru.external_response }
      row :verified
      row :created_at
      row :updated_at
      row :sku
      row('SKU synchronized at') { ru.sku_synchronized_at }
    end

    Channel.all.each do |channel|
      access = ChannelAccess.for(channel, ru)
      if access.banned
        link = link_to("Unban access", unban_channel_access_path(access))
      else
        link = link_to("Ban access", ban_channel_access_path(access))
      end
      attributes_table title: "Activity for channel: #{channel.name} / #{link}".html_safe do
        access.reasons.each do |reason|
          reason = reason.split(" - ", 2)
          reason = [access.created_at, reason[0].to_s.titleize] if reason.length < 2
          row(reason[0]) { reason[1] }
        end
      end
    end
    active_admin_comments
  end
end
