class SamplesController < ApplicationController
	require 'pry'

	def index
	end

	def analyze

		@sample = Sample.new(sample_params)

		caller = AlchemyCaller.new(@sample)
		caller.call_API
		caller.convert_to_keyword_objects

		@keywords = @sample.keywords
		calculator = MetricsCalculator.new(@sample.keywords)
		@averages = calculator.return_averages_by_gender

		@sample.user_id = session[:user_id]
		@sample.save

		render 'new'

	end

  def create
    puts @sample.text
  end

	def new
	end

	def show
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
		params.require(:sample).permit(:content)
	end
end
