# app/controllers/comments_controller.rb
class CommentsController < ApplicationController
  before_action :set_post
  before_action :set_comment, only: [ :edit, :update ]

  def create
    @comment = @post.comments.new(comment_params.merge(user: current_user))
    if @comment.save
      redirect_to @post, notice: "Comment added."
    else
      redirect_to @post, alert: @comment.errors.full_messages.to_sentence
    end
  end

  def edit
    # Renders edit view
  end

  def update
  return redirect_to @post, alert: "Not allowed" unless @comment.user == current_user

  if @comment.update(comment_params)
    respond_to do |format|
      format.turbo_stream   # renders update.turbo_stream.erb (success)
      format.html { redirect_to @post, notice: "Comment updated." }
    end
  else
    respond_to do |format|
      # render the edit form HTML back into the frame
      format.turbo_stream { render :edit, status: :unprocessable_entity, formats: :html }
      format.html         { render :edit, status: :unprocessable_entity }
    end
  end
  end

  def destroy
  comment = @post.comments.find_by(id: params[:id])
  return head :ok unless comment
  return head :forbidden unless comment.user == current_user

  comment.destroy
  counter_id = view_context.dom_id(@post, :comments_count)

  respond_to do |format|
    format.turbo_stream do
      render turbo_stream: [
        turbo_stream.remove(comment),  # removes the comment frame (id = comment_XX)
        turbo_stream.update(counter_id) {
          # re-render the  pill
          view_context.tag.span("💬") +
          view_context.tag.span(" #{view_context.pluralize(@post.reload.comments_count, 'comment')}")
        }
      ]
    end
    format.html { redirect_to @post, notice: "Comment deleted." }
  end
  end
  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_comment
    @comment = @post.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
