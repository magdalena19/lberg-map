class RemoveDefaultValuesFromCategoryStyleColumns < ActiveRecord::Migration
  def change
    change_column_default :categories, :marker_color, nil
    change_column_default :categories, :marker_shape, nil
    change_column_default :categories, :marker_icon_class, nil
  end
end
