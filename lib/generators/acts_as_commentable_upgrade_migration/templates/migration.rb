class ActsAsCommentableUpgradeMigration < ActiveRecord::Migration
  def self.up
    rename_column :comments, :comment, :body
    add_column :comments, :subject, :string
    add_column :comments, :ancestry, :string
    add_column :comments, :updated_at, :datetime

    add_index :comments, :commentable_id
  end

  def self.down
    rename_column :comments, :body, :comment
    remove_column :comments, :subject
    remove_column :comments, :ancestry
    remove_column :comments, :updated_at

    remove_index :comments, :commentable_id
  end
end
