class IncreaseValidityRangePrecision < ActiveRecord::Migration[5.0]
  def change
    change_column :dag_links, :valid_from, :datetime, limit: 6
    change_column :dag_links, :valid_to, :datetime, limit: 6
  end
end
