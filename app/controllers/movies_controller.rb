class MoviesController < ApplicationController

  # See Section 4.5: Strong Parameters below for an explanation of this method:
  # http://guides.rubyonrails.org/action_controller_overview.html
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @movies = Movie.all
    @sorter = 0
    @release_date_sort = ''
    @title_sort = ''


    if(@the_ratings != nil)
      @movies = @movies.find_all{ |movie| @the_ratings.has_key?(movie.rating) and @the_ratings[movie.rating]==true}
    end


    if(params[:sort].to_s == 'title')
      session[:sort] = params[:sort]
      @title_sort = 'hilite'
      @release_date_sort = ''
      @movies = @movies.sort_by{|movie| movie.title.to_s}
    elsif(params[:sort].to_s == 'release')
      session[:sort] = params[:sort]
      @release_date_sort = 'hilite'
      @title_sort = ''
      @movies = @movies.sort_by{|movie| movie.release_date.to_s}
    elsif(session.has_key?(:sort))
      params[:sort] = session[:sort]
      @sorter = 1
    end


    if(params[:ratings]!=nil)
      session[:ratings] = params[:ratings]
      @movies = @movies.find_all{ |movie| params[:ratings].has_key?(movie.rating)}
    elsif(session.has_key?(:ratings))
      params[:ratings] = session[:ratings]
      @sorter = 1
    end


    if(@sorter == 1)
      redirect_to movies_path(:sort=>params[:sort], :ratings=>params[:ratings])
    end

    @the_ratings = {}
    @all_ratings = ['G','PG','PG-13','R','NC-17']


    @all_ratings.each do |rating, value|
      if params[:ratings] == nil
        @the_ratings[rating] = true
      else
        @the_ratings[rating] = params[:ratings].has_key?(rating)
      end
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private :movie_params
  
end
