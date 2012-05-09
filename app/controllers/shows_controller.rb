require 'tvdb_party' #documentation: http://rubydoc.info/gems/tvdb_party/0.6.2/frames

class ShowsController < ApplicationController

	def show
		@show = Show.find(params[:id])
		sign_in_show @show
		@microposts = @show.microposts.paginate(:page => params[:page])
		@micropost = Micropost.new
	end

	def index
		@shows = Show.paginate(:page => params[:page], :per_page => 10, :order => :name)
	end

	def new
		@show = Show.new
	end

	def create
		tvdb = TvdbParty::Search.new("F6EA8F2FD26C08BF")
		@show = Show.new(params[:show])
		@results = tvdb.search(@show.name)
		@seriesid = ""

		@results.each_index do |res|
			if @results[res]["SeriesName"].upcase == @show.name.upcase #This matches the show name exactly

				@show.name = @results[res]["SeriesName"]
				@show.description = @results[res]["Overview"]
#				@show.banner = @results[res]["banner"]
				@show.seriesid = @results[res]["seriesid"]

				if @show.save #only saves if there are no duplicates
#					@show.delay.fill @results[res]["seriesid"] #this only works if you have a computer doing rake jobs:work
					flash[:success] = "Show Added Successfully!"
					@show.fill @show.seriesid
					redirect_to @show
					return #This needs to be here to prevent a rails error, so says Rails
				else
					flash.now[:error] = "ERROR: Show Not Added"
					@results.delete_at(res) #remove from results array so we don't suggest the same show on the error page
				end
			end
		end

		render 'error'

	end
	
	def search
		@show = ''
		@search = params[:name]
		
		if !@search.nil?
			@result = Show.select(:id).where("upper(name) LIKE ?", "%"+@search.upcase+"%").map(&:id)
			if @result.empty?
				render 'noresult'
			elsif @result.count == 1
			  redirect_to :action => "show", :id => @result
			else 
			  @shows = []
	      @result.each do |match|		  
  			  @shows << Show.find(match)
  			end
				render 'matches'
			end
		end
	end
	
	
	
	
	
	
	
	
	
	
end
