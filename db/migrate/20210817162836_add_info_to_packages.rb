class AddInfoToPackages < ActiveRecord::Migration[6.1]
  def change
    add_column :packages, :date_publication, :string
    add_column :packages, :title, :string
    add_column :packages, :description, :string
    add_column :packages, :authors, :string
    add_column :packages, :maintainers, :string
  end
end
