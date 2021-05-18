module Util

  module Attribution

    def self.included(base)
      if base.has_column?(:owner_id)
        base.send :include, OwnerMethods
      else
        base.send :include, NoOwnerMethods
      end

      if base.has_column?(:author_id)
        base.send :include, AuthorMethods
        base.send :include, OwnerAuthorMethods
      end
    end

    module OwnerMethods

      def owned_by?(user)
        owner_id && user.id ? owner_id == user.id : owner == user
      end

    end

    module NoOwnerMethods

      def owner
        object.owner if object.respond_to?(:owner)
      end

      def owned_by?(user)
        owner == user if owner
      end

    end

    module AuthorMethods

      def by?(user)
        author_id && user.id ? author_id == user.id : author == user
      end

    end

    module OwnerAuthorMethods

      def by_owner?
        by?(owner) if owner
      end

    end

  end

end
