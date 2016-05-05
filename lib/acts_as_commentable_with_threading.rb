require 'active_record'

# ActsAsCommentableWithThreading
module ThreadableComments #:nodoc:
  extend ActiveSupport::Concern

  module ClassMethods
    def has_threadable_comments
      has_many :comment_threads, class_name: 'Comment', as: :commentable
      before_destroy { |record| record.root_comments.destroy_all }
      include ThreadableComments::InstanceMethods
      extend ThreadableComments::KlassMethods
    end
  end

  # This module contains class methods
  module KlassMethods
    # Helper method to lookup for comments for a given object.
    # This method is equivalent to obj.comments.
    def find_comments_for(obj)
      Comment.where(commentable_id: obj.id,
                    commentable_type: obj.class.base_class.name)
          .order('created_at DESC')
    end

    # Helper class method to lookup comments for
    # the mixin commentable type written by a given user.
    # This method is NOT equivalent to Comment.find_comments_for_user
    def find_comments_by_user(user)
      commentable = base_class.name.to_s
      Comment.where(user_id: user.id, commentable_type: commentable)
          .order('created_at DESC')
    end
  end

  module InstanceMethods
    # Helper method to display only root threads, no children/replies
    def root_comments
      comment_threads.roots
    end

    # Helper method to sort comments by date
    def comments_ordered_by_submitted
      Comment.where(commentable_id: id, commentable_type: self.class.name)
          .order('created_at DESC')
    end

    # Helper method that defaults the submitted time.
    def add_comment(text, user)
      comment_threads << Comment.create(commentable: self, body: text, user_id: user.id)
    end
  end
end

ActiveRecord::Base.send(:include, ThreadableComments)
