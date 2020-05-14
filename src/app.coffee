import m from 'mithril'
import SearchBar from './components/search-bar.coffee'
import MovieCard from './components/movie-card.coffee'
import AddModal from './components/add-modal.coffee'
import DB from './lib/db.coffee'
import GistDB from './lib/gist.coffee'
import Swal from 'sweetalert2'

EmptyMessage = () ->
  view: (vnode) ->
    {show} = vnode.attrs
    m 'p.empty', {
      style: "display: #{if show then 'block' else 'none'}"
    }, 'Your watch list is empty'

updateGistInfo = (cb) ->
  Swal.fire {
    title: 'Gist information'
    html:
      '<input id="token" placeholder="Github token" class="swal2-input">' +
      '<input id="gist-id" placeholder="Gist ID (optional)" class="swal2-input">'
    focusConfirm: false
    preConfirm: () ->
      [
        document.getElementById('token').value,
        document.getElementById('gist-id').value
      ]
  }
  .then ({ value: formValues }) ->
    GistDB.saveGistInfo formValues[0], formValues[1]
    GistDB.loadGist()
    if cb?
      cb()

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
        style: '
          position: fixed;
          z-index: 1000;
          background: white;
          top: 0;
          left: 0;'
        onchange: (e) ->
          searchTerm = e.target.value
      }
      m EmptyMessage, { show: DB.movies.length == 0 }
      m '.grid',
        DB.movies
        .slice()
        .reverse()
        .filter (movie) ->
          movie.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
          movie.directors.some (director) ->
            director.toLowerCase().includes(searchTerm.toLowerCase())
        .map (movie) ->
          m '.col-4.col-2-sm', m MovieCard, {
            movie,
            onwatchclick: () ->
              movie.watchcount++
              DB.saveMovies()
            onremoveclick: () ->
              DB.removeMovie(movie.id)
          }
      m '.tools', [
        m 'span.tool', {
          onclick: () ->
            showAddModal = true
        }, m 'i.fa.fa-plus'
        m 'span.tool', {
          onclick: () ->
            updateGistInfo()
        }, m 'i.fa.fa-cloud'
        m 'span.tool', {
          onclick: () ->
            if !GistDB.hasEnoughInfo()
              updateGistInfo () ->
                GistDB.push DB.movies
            else
              if !GistDB.isLoaded()
                GistDB.loadGist()
              GistDB.push DB.movies
        }, m 'i.fa.fa-cloud-upload'
        m 'span.tool', {
          onclick: () ->
            if !GistDB.hasEnoughInfo()
              updateGistInfo () ->
                GistDB.pull (movies) ->
                  DB.movies = movies
                  DB.saveMovies()
                  m.redraw()
            else
              if !GistDB.isLoaded()
                GistDB.loadGist()
              GistDB.pull (movies) ->
                DB.movies = movies
                DB.saveMovies()
                m.redraw()
        }, m 'i.fa.fa-cloud-download'
      ]
    ]
