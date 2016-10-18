class Movie < ActiveRecord::Base
  def self.all_ratings
    %w(G PG PG-13 NC-17 R)
  end

  class Movie::InvalidKeyError < StandardError ; end

  def self.find_in_tmdb(string)
    begin
      Tmdb::Api.key('f4702b08c0ac6ea5b51425788bb26562')
      movies = Tmdb::Movie.find(string)
      results = []
      if not movies.blank?
        movies.each do |movie|
          hash = {}
          movie_releases = Tmdb::Movie.releases(movie.id)
          if movie_releases["countries"] != nil
            movie_releases["countries"].each do |movie_release|
              if movie_release["iso_3166_1"] === "US"
                hash[:tmdb_id] = movie.id
                hash[:title] = movie.title
                hash[:rating] = movie_release["certification"]
                hash[:release_date] = movie_release["release_date"]
                if !hash[:rating].blank?
                  results.push(hash)
                  break
                end
              end
            end
          end
        end
      end
      return results
    rescue NoMethodError => tmdb_gem_exception
      if Tmdb::Api.response['code'] == '401'
       raise Movie::InvalidKeyError, 'Invalid API key'
      else
        raise tmdb_gem_exception
      end
    end
  end

  def self.create_from_tmdb(tmdb_id)
    begin
      Tmdb::Api.key('f4702b08c0ac6ea5b51425788bb26562')
      movie_detail = Tmdb::Movie.detail(tmdb_id)
      if movie_detail != nil
        release = Tmdb::Movie.releases(tmdb_id)["countries"].select { |m| m["iso_3166_1"] === "US" && !m["certification"].blank?}
        rating = release[0]["certification"]
        rating = "Not Rated" if rating.blank?
        new_movie = {title: movie_detail["title"], rating: rating, release_date: movie_detail["release_date"], description: movie_detail["overview"]}
        Movie.create(new_movie)
      end
    rescue NoMethodError => tmdb_gem_exception
      if Tmdb::Api.response['code'] == '401'
       raise Movie::InvalidKeyError, 'Invalid API key'
      else
        raise tmdb_gem_exception
      end
    end
  end
end