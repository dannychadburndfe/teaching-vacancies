class PostsController < ApplicationController
  before_action :render_not_found_unless_post_exist, only: :show

  helper_method :post, :posts

  private

  def render_not_found_unless_post_exist
    not_found unless post.exist?
  end

  def post
    @post ||= MarkdownDocument.new(params[:section], params[:post_name])
  end

  def posts
    @posts ||= MarkdownDocument.all(params[:section])
  end
end
