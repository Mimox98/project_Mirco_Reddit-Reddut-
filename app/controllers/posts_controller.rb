# app/controllers/posts_controller.rb
class PostsController < ApplicationController
  def index
    @posts = Post.order(created_at: :desc).includes(:user)
  end

  def show
    @post = Post.find(params[:id])
    @comments = @post.comments.includes(:user).order(created_at: :asc)
    @comment = Comment.new
  end

  def new
    @post = Post.new
  end

  def create
    @post = current_user.posts.new(post_params)
    if @post.save
      redirect_to @post, notice: "Posted!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
  @post = Post.find(params[:id])
  if @post.user == current_user
    @post.destroy
    redirect_to posts_path, notice: "Post deleted."
  else
    redirect_to posts_path, alert: "You can only delete your own posts."
  end
  end


  #  voting endpoint
  def nudge_score
    post = Post.find(params[:id])
    delta = params[:delta].to_i.clamp(-2, 2)
    post.update_columns(score: post.score + delta)
    render json: { score: post.reload.score }
  end

  private
  def post_params
    params.require(:post).permit(:subreddit, :title, :body, :image_url)
  end
end
