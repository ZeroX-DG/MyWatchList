import m from 'mithril'
import SearchBar from './components/search-bar.coffee'
import MovieCard from './components/movie-card.coffee'
import AddModal from './components/add-modal.coffee'
import DB from './lib/db.coffee'

EmptyMessage = () ->
  view: (vnode) ->
    {show} = vnode.attrs
    m 'p.empty', {
      style: "display: #{if show then 'block' else 'none'}"
    }, 'Your watch list is empty'

export default () =>
  showAddModal = false
  searchTerm = ''
  oninit: ->
    DB.getMovies() # load movie list
  view: ->
    m '#wrapper', [
      m AddModal, {
        show: showAddModal,
        onAddMovieClick: (movie) ->
          DB.addMovie(movie)
          m.redraw()
        onclose: () ->
          showAddModal = false
      }
      m SearchBar, {
        onchange: (e) ->
          searchTerm = e.target.value
      }
      m EmptyMessage, { show: DB.movies.length == 0 }
      m '.row', { style: 'margin-top: 25px' },
        DB.movies
        .filter (movie) ->
          movie.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
          movie.directors.some (director) ->
            director.toLowerCase().includes(searchTerm.toLowerCase())
        .map (movie) ->
          m '.col-4', m MovieCard, {
            movie,
            onwatchclick: () ->
              movie.watchcount++
            onremoveclick: () ->
              DB.removeMovie(movie.id)
          }
      m 'button#add-btn', {
        onclick: () ->
          showAddModal = true
      }, m 'i.fa.fa-plus'
    ]
