
describe Movie do
  describe 'searching Tmdb by keyword' do
    context 'with valid key' do
      it 'should call Tmdb with title keywords' do
        expect(Tmdb::Movie).to receive(:find).with('Inception')
        Movie.find_in_tmdb('Inception')
      end
    end
    context 'with invalid key' do
      it 'should raise InvalidKeyError if key is missing or invalid' do
        allow(Tmdb::Movie).to receive(:find).and_raise(NoMethodError)
        allow(Tmdb::Api).to receive(:response).and_return({'code' => '401'})
        expect { Movie.find_in_tmdb('Inception') }.to raise_error(Movie::InvalidKeyError)
      end
    end
    context 'with zero results' do
      it 'should return an empty array' do
        allow(Tmdb::Movie).to receive(:find).with('No such movie with this name').and_return(nil)
        expect(Movie.find_in_tmdb('No such movie with this name')).to eq([])
      end
    end
    context 'with many results' do
      it 'should return an array of hashes' do
        finds = [double("movie1"), double('movie2')]
        releases = [{"countries" => [{"certification" => "G", "iso_3166_1" => "US"}]}, {"countries" => [{"certification" => "PG", "iso_3166_1" => "US"}]}]
        allow(finds[0]).to receive(:id).and_return("0")
        allow(finds[0]).to receive(:title).and_return("Title1")
        allow(finds[1]).to receive(:id).and_return("1")
        allow(finds[1]).to receive(:title).and_return("Title2")
        allow(Tmdb::Movie).to receive(:find).with('Inception').and_return(finds)
        allow(Tmdb::Movie).to receive(:releases).with('0').and_return(releases[0])
        allow(Tmdb::Movie).to receive(:releases).with('1').and_return(releases[1])
        results = Movie.find_in_tmdb('Inception')
        expect(results[0][:tmdb_id]).to eq("0")
        expect(results[1][:tmdb_id]).to eq("1")
        expect(results[0][:title]).to eq("Title1")
        expect(results[1][:title]).to eq("Title2")
        expect(results[0][:rating]).to eq("G")
        expect(results[1][:rating]).to eq("PG")
      end
      it 'should return nothing for movies without ratings' do
        finds = [double("movie1")]
        release = {"countries" => [{"certification" => "", "iso_3166_1" => "US"}]}
        allow(finds[0]).to receive(:id).and_return("0")
        allow(finds[0]).to receive(:title).and_return("Title1")
        allow(Tmdb::Movie).to receive(:find).with('Inception').and_return(finds)
        allow(Tmdb::Movie).to receive(:releases).with('0').and_return(release)
        results = Movie.find_in_tmdb('Inception')
        expect(results[0]).to eq(nil)
      end
    end
  end
  describe 'adding from Tmdb by id' do
    context 'with valid key' do
      it 'should call Tmdb with title keywords' do
        expect(Tmdb::Movie).to receive(:find).with('Inception')
        Movie.find_in_tmdb('Inception')
      end
    end
    context 'with invalid key' do
      it 'should raise InvalidKeyError if key is missing or invalid' do
        allow(Tmdb::Movie).to receive(:find).and_raise(NoMethodError)
        allow(Tmdb::Api).to receive(:response).and_return({'code' => '401'})
        expect { Movie.create_from_tmdb(0) }.to raise_error(Movie::InvalidKeyError)
      end
    end

    context 'with valid movie' do
      it 'should add the movie to the database' do
        movie_details = {"title" => "title", "release_date" => "2015-01-01", "overview" => "description"}
        releases = {"countries" => [{"certification" => "G", "iso_3166_1" => "US"}]}
        allow(Tmdb::Movie).to receive(:detail).and_return(movie_details)
        allow(Tmdb::Movie).to receive(:releases).and_return(releases)
        results = Movie.create_from_tmdb(0)
        expect(results["title"]).to eq(movie_details["title"])
        expect(results["release_date"]).to eq(movie_details["release_date"])
        expect(results["description"]).to eq(movie_details["overview"])
        expect(results["rating"]).to eq("G")
      end
    end
  end
end
