DB =
  movies: []
  getMovies: () ->
    raw_json = localStorage.getItem 'movies'
    @movies = JSON.parse(raw_json) || []

  saveMovies: () ->
    localStorage.setItem 'movies', JSON.stringify @movies

  hasMovie: (movieId) ->
    @movies.some (movie) -> movie.id == movieId

  removeMovie: (movieId) ->
    @movies = @movies.filter (movie) -> movie.id != movieId
    @saveMovies()

  addMovie: (movie) ->
    @movies.push movie
    @saveMovies()

export default DB
