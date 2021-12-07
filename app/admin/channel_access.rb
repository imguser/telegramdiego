ActiveAdmin.register ChannelAccess do
  permit_params :name, :value
  scope :all, default: true

  action_item :ban, priority: 0, only: :show, if: proc{ !channel_access.banned } do
    link_to "Ban access", ban_channel_access_path
  end

  action_item :unban, priority: 0, only: :show, if: proc{ channel_access.banned } do
    link_to "Unban access", unban_channel_access_path
  end

  member_action :ban, method: :get do
    resource.registered_user.ban_channel(resource.channel_id)
    redirect_to request.referer || resource_path, notice: "User was banned!"
  end

  member_action :unban, method: :get do
    resource.registered_user.unban_channel(resource.channel_id)
    redirect_to request.referer || resource_path, notice: "User was unbanned!"
  end

  actions :all

  index do
    selectable_column
    id_column
    column :banned
    column :active
    column :channel
    column :registered_user
  end

  show do |ca|
    attributes_table do
      row("#id") { ca.id }
      row(:banned)
      row(:valid_details)
      row(:matching_sku)
      row(:restricted)
      row(:channel)
      row(:registered_user)
    end

    attributes_table title: "Reasons:" do
      ca.reasons.each do |reason| 
        row('-') { reason }
      end
    end

  end
end
