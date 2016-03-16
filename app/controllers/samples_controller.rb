class SamplesController < ApplicationController
  def index
  end

  def input_text
  end

  def analyze
    caller = APICoordinator.new(params)
    caller.call_API
    sample = caller.create_sample
    keywords = caller.create_keywords

    sample.user_id = session[:user_id]
    sample.save
    render json: { sample: sample, keywords: keywords }

  end

  def create
    puts @sample.text
  end


  def new
  end

  def destroy
    @sample = Sample.find(params[:id])
    @sample.destroy
    @sample.keywords.destroy_all
    if current_user
      redirect_to user_path(current_user.id)
    else
      redirect_to root_path
    end
  end

  private
  def sample_params
    params.require(:sample).permit(:content, :name)
  end
end
