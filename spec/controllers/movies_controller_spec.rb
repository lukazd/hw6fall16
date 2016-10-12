require 'spec_helper'
require 'rails_helper'

describe MoviesController do
  describe 'searching TMDb' do
   it 'should call the model method that performs TMDb search' do
      fake_results = [double(movie1 = {:tmdb_id => "1",:title => "title1", :rating => "R", :release_date => "2015-10-10" }), double(movie1 = {:tmdb_id => "2",:title => "title2", :rating => "PG", :release_date => "2015-10-11" })]
      expect(Movie).to receive(:find_in_tmdb).with('Ted').
        and_return(fake_results)
      post :search_tmdb, {:search_terms => 'Ted'}
    end
    it 'should flash a message for blank queries' do
      expect(Movie).not_to receive(:find_in_tmdb)
      post :search_tmdb, {:search_terms => ' '}
      expect(flash[:alert]).to match(/Invalid search term/)
      expect(response).to redirect_to(movies_path)
    end
    it 'should select the Search Results template for rendering' do
      allow(Movie).to receive(:find_in_tmdb)
      post :search_tmdb, {:search_terms => 'Ted'}
      expect(response).to render_template('search_tmdb')
    end
    it 'should make the TMDb search results and search query available to that template' do
      fake_results = [double(movie1 = {:tmdb_id => "1",:title => "title1", :rating => "R", :release_date => "2015-10-10" }), double(movie1 = {:tmdb_id => "2",:title => "title2", :rating => "PG", :release_date => "2015-10-11" })]
      query = 'Ted'
      allow(Movie).to receive(:find_in_tmdb).and_return (fake_results)
      post :search_tmdb, {:search_terms => query}
      expect(assigns(:movies)).to eq(fake_results)
      expect(assigns(:search_terms)).to eq(query)
    end
  end
end
