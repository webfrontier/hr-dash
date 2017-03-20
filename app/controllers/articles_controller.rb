# frozen_string_literal: true
class ArticlesController < ApplicationController
  def index
    references = [:user, { article_tags: :tag }]
    @articles = Article.includes(references).released.order('shipped_at desc').page params[:page]
  end

  def show
    @article = Article.includes(comments: { user: :user_profile }).find(params[:id])
    raise(Forbidden, 'can not see wip articles of other users') unless browseable?(@article)
  end

  def new
    @article = current_user.articles.build
  end

  def create
    @article = Article.new(permitted_params) do |article|
      article.user = current_user
      assign_relational_params(article)
    end

    if @article.save
      redirect_to @article
    else
      flash_errors(@article)
      render :new
    end
  end

  def edit; end

  def update; end

  def destroy; end

  private

  def permitted_params
    params.require(:article).permit(
      :title,
      :body,
    )
  end

  def flash_errors(article)
    flash.now[:error] = article.errors.full_messages
  end

  def assign_relational_params(article)
    article.shipped! unless params[:wip]
    article.tags = article_tags
  end

  def article_tags
    tags = params[:article][:article_tags].try!(:split, ',').try!(:map) do |name|
      tag = Tag.find_or_initialize_by_name_ignore_case(name.strip)
      tag.save ? tag : nil
    end.try!(:compact)

    tags || []
  end

  def browseable?(article)
    article.browseable?(current_user)
  end
end