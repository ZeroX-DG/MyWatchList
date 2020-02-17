import m from 'mithril'
import DB from '../lib/db.coffee'
import SearchBar from './search-bar.coffee'
import './add-modal.sass'

MovieCard = () ->
  view: (vnode) ->
    { id, title, thumb, img, year, directors } = vnode.attrs.movie
    { onAddMovieClick } = vnode.attrs
    movieAlreadyInList = DB.hasMovie(id)
    m '.movie-card-search', [
      m 'img.movie-img', { src: thumb }
      m '.info', [
        m 'p.meta', [
          m 'span.directors', directors.join(', ')
          m 'span.year', year
        ]
        m 'h2.title', title
      ]
      unless movieAlreadyInList
        m 'button.add-button', {
          onclick: () ->
            onAddMovieClick(vnode.attrs.movie)
        }, 'Add to watchlist'
    ]

getSearchApiUrl = (searchTerm) ->
  return "https://mubi.com/services/api/search?query=#{searchTerm}&per_page=9"

getSearchResult = (searchTerm, cb) ->
  url = getSearchApiUrl searchTerm
  fetch url
    .then (resp) -> resp.json()
    .then (data) ->
      result = data.films.map (raw_movie) ->
        if !raw_movie.stills?
          return
        movie =
          id: raw_movie.id
          title: raw_movie.title
          year: raw_movie.year
          directors: raw_movie.directors.map (director) -> director.name
          thumb: raw_movie.stills.square
          img: raw_movie.stills.medium
          watchcount: 0
      .filter (movie) -> movie
      cb(result)

export default () ->
  searchTerm = ''
  searchResult = []
  searchWait = null
  view: (vnode) ->
    { show, onAddMovieClick, onclose } = vnode.attrs
    m '.search-modal-wrapper',
      m '.search-overlay', {
        onclick: onclose
        style: "display: #{if show then 'block' else 'none'}"
      },
      m '.search-modal', {
        style: "
          height: #{if searchResult.length > 0 then '70%' else '110px'};
          display: #{if show then 'block' else 'none'}
        ",
        onclick: (e) -> e.stopPropagation()
      }, [
        m SearchBar, {
          onchange: (e) ->
            searchTerm = e.target.value
            if searchWait?
              clearTimeout(searchWait)
            searchWait = setTimeout () ->
              clearTimeout(searchWait)
              searchWait = null
              getSearchResult searchTerm, (result) ->
                searchResult = result
                m.redraw()
            , 500
        }
        m '.result-list',
          m '.row', searchResult.map (movie) ->
            m '.col-12',
              m MovieCard, { movie, onAddMovieClick }
        m '.credit', 'A big thank you to Mubi.com for the movie database and API'
      ]
