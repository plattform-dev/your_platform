class RootController < ApplicationController
  
  before_action :redirect_to_setup_if_needed
  before_action :redirect_to_sign_in_if_needed, :find_and_authorize_page

  def index
    set_current_navable @page
    set_current_activity :looks_at_the_start_page, @page
    set_current_access :user
    set_current_access_text :the_content_of_the_start_page_is_personalized
        
    # @notifications = current_user.notifications.order('created_at desc').limit(15)
    @announcement_page = Page.find_or_create_by_flag :site_announcement
    @blog_entries = @news_pages = current_user.news_pages.limit(15).select { |page| can?(:read, page) and (page.attachments.count > 0 or (page.content && page.content.length > 5)) } - [@page, @announcement_page]
    @posts = current_user.posts_for_me.order('created_at desc').limit(10)
    @posts_by_mentions = current_user.mentions.order('created_at desc').limit(10).collect do |mention|
      if mention.reference.kind_of? Post
        mention.reference
      elsif mention.reference.kind_of?(Comment) and mention.reference.commentable.kind_of?(Post)
        mention.reference.commentable
      end
    end
            
    #@objects = (@notifications.map(&:reference) + @blog_entries).sort_by { |obj| obj.updated_at }.reverse
    @objects = (@posts + @blog_entries + @posts_by_mentions).uniq.sort_by { |obj| obj.updated_at }.reverse
  end
  
  
private

  def redirect_to_setup_if_needed
    if User.count == 0
      @need_setup = true
      redirect_to setup_path
    end
  end
  
  # If a public website exists, which is not just a redirection, then signed-out
  # users are shown the public website.
  #
  # If no public website exists, the users are shown sign-in form.
  # 
  def redirect_to_sign_in_if_needed
    unless current_user or @need_setup
      if Page.public_website_present?
        redirect_to Page.public_root
      else
        redirect_to sign_in_path
      end
    end
  end

  def find_and_authorize_page
    @page = Page.find_intranet_root
    @navable = @page
    authorize! :show, @page
  end
  
end
