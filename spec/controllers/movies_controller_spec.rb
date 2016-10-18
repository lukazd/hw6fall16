require 'spec_helper'
require 'rails_helper'

describe MoviesController do
  describe 'searching TMDb' do
   it 'should call the model method that performs TMDb search' do
      fake_results = [double('movie1'), double('movie2')]
      expect(Movie).to receive(:find_in_tmdb).with('Ted').
        and_return(fake_results)
      post :search_tmdb, {:search_terms => 'Ted'}
    end
    it 'should flash a message for blank queries' do
      expect(Movie).not_to receive(:find_in_tmdb)
      post :search_tmdb, {:search_terms => ' '}
      expect(flash[:warning]).to match(/Invalid search term/)
      expect(response).to redirect_to(movies_path)
    end
    it 'should flash a message for no results' do
      fake_results = nil
      expect(Movie).to receive(:find_in_tmdb).with('@#^%#').and_return(fake_results)
      post :search_tmdb, {:search_terms => '@#^%#'}
      expect(flash[:warning]).to match(/No matching movies/)
      expect(response).to redirect_to(movies_path)
    end
    it 'should select the Search Results template for rendering' do
      allow(Movie).to receive(:find_in_tmdb).and_return(double('result'))
      post :search_tmdb, {:search_terms => 'Ted'}
      expect(response).to render_template('search_tmdb')
    end
    it 'should make the TMDb search results available to that template' do
      fake_results = [double('Movie'), double('Movie')]
      query = 'Ted'
      allow(Movie).to receive(:find_in_tmdb).and_return (fake_results)
      post :search_tmdb, {:search_terms => query}
      expect(assigns(:movies)).to eq(fake_results)
    end
    it 'should make the TMDb search query available to that template' do
      fake_results = [double('movie1'), double('movie2')]
      query = 'Ted'
      allow(Movie).to receive(:find_in_tmdb).and_return (fake_results)
      post :search_tmdb, {:search_terms => query}
      expect(assigns(:search_terms)).to eq(query)
    end
  end

  describe 'adding from TMDb' do
    it 'should flash a message for no movies selected' do
      expect(Movie).not_to receive(:create_from_tmdb)
      post :add_tmdb, {:tmdb_movies => {}}
      expect(flash[:warning]).to match(/No movies selected/)
      expect(response).to redirect_to(movies_path)
    end
    it 'should flash a message for successful addition' do
      movie = {double("movie") => 0}
      expect(Movie).to receive(:create_from_tmdb)
      post :add_tmdb, {:tmdb_movies => movie}
      expect(flash[:notice]).to match(/Movies successfully added/)
      expect(response).to redirect_to(movies_path)
    end
    it 'should add all movies checked by user' do
      movies = {double("movie1") => 0, double("movie2") => 1, double("movie3") => 2}
      expect(Movie).to receive(:create_from_tmdb).exactly(3).times
      post :add_tmdb, {:tmdb_movies => movies}
    end
  end
end
