class Public::PostsController < ApplicationController

  def new
    @post = Post.new
  end

  def show
    @post = Post.find(params[:id])
    @post_comment = PostComment.new
    @post_tags = @post.tags
  end

  def index
    @user = current_user
    @post = Post.new
    @posts = Post.all.page(params[:page]).per(5)
    @tag_list = Tag.all.page(params[:page]).per(5)
    @post_like_ranks = Post.find(Favorite.group(:post_id).order('count(post_id) desc').limit(5).pluck(:post_id))
    @tag_like_ranks = Tag.find(PostTag.group(:tag_id).order('count(tag_id) desc').limit(5).pluck(:tag_id))
  end

  def edit
    @post = Post.find(params[:id])
    @tag_list = @post.tags.pluck(:name).join(',')
  end

  def create
    @post = Post.new(post_params)
    @post.user_id = current_user.id
    tag_list = params[:post][:name].split(',')
   if @post.save
      @post.save_tag(tag_list)
      redirect_to post_path(@post.id),notice:'投稿完了しました'
   else
      flash[:notice] = "タイトル、内容どちらも入力必須です"
      redirect_back(fallback_location: root_path)
   end
  end



  def update
    @post = Post.find(params[:id])
    tag_list = params[:post][:name].split(',')
    if @post.update(post_params)
      @post.save_tag(tag_list)
      redirect_to post_path(@post.id),notice:'編集完了しました'
    else
      render :edit
    end
  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    redirect_to posts_path
  end

  def search_tag
    #検索結果画面でもタグ一覧表示
    @tag_list=Tag.all
    #検索されたタグを受け取る
    @tag=Tag.find(params[:tag_id])
    #検索されたタグに紐づく投稿を表示
    @posts=@tag.posts.page(params[:page]).per(10)
  end

 private

  def post_params
    params.require(:post).permit(:title, :body, :image)
  end
end