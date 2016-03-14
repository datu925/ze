class UsersController < ApplicationController

  def index
    @users = User.all
    redirect_to '/'
  end
  
  def search
    user = User.find(session[:user_id])
    query = params[:query].downcase
    @sample_matches = []  
    key_matches = []
    @frequency = Hash.new(0)

    user.samples.each do |sample| 
      if sample.keywords.any?
        sample.keywords.each do |keyword|
          key_matches << keyword
        end
      end
    end

    @key_matches = key_matches.select {|key| key.text.downcase.match(/(#{query})/)}
    @key_matches.each {|key| @sample_matches << key.sample}
    @sample_matches.uniq!
    
    @key_matches.each do |key| 
      sample_data = key.sample.content.split(" ")
      sample_data.each do |word|
        if word == key.text.split(" ")[0]
          @frequency[key.text] += 1
        end
      end
    end
    # returns @frequency hash, @sample_matches array of matched samples to keys, and @key_matches to the user's query
  end

  def show
    if logged_in?
      @user = User.find(params[:id])
    else
      redirect_to '/'
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      redirect_to '/'
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to @user
    else
      redirect_to @user
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    flash.notice = "#{@user.name} has been destroyed."
    redirect_to '/'
  end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end


end
