ActiveAdmin.register GlobalSnippet do
  permit_params :name, :value

  index do
    selectable_column
    id_column
    column :name
    column :value
    actions
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :name
      f.input :value
    end
    f.actions
  end
end
