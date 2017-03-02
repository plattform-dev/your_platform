concern :GroupCaching do

  # Make sure this concern is included at the bottom of the class.
  # Otherwise, the methods to be cached are not declared, yet.
  #
  included do
    after_commit(on: [:create, :update]) { self.delay.renew_cache }

    cache :corporation_id
    cache :leaf_groups

    cache :group_of_groups?
    cache :name_with_corporation
  end

  def delete_cache
    super
    ancestor_groups(true).each { |g| g.delete_cached(:leaf_groups); g.delete_cached(:status_groups) }
  end

  def renew_cache
    super
    Rails.cache.renew do
      ancestor_groups(true).each { |g| g.leaf_groups; g.status_groups }
    end
  end

  include StructureableRoleCaching
end