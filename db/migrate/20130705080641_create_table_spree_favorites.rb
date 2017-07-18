migration_superclass = if ActiveRecord::VERSION::MAJOR >= 5
  ActiveRecord::Migration["#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}"]
else
  ActiveRecord::Migration
end

class CreateTableSpreeFavorites < migration_superclass
  def change
    create_table :spree_favorites do |t|
      t.belongs_to :favorable, polymorphic: true
      t.belongs_to :user
      t.string :guest_token
      t.timestamps
    end
    add_index :spree_favorites, [:favorable_id, :favorable_type]
    add_index :spree_favorites, :user_id
    add_index :spree_favorites, :guest_token
  end
end
