import Gists from 'gists'

gistID = localStorage.getItem 'gistID'
gistToken = localStorage.getItem 'gistToken'
gists = null

GistDB =
  loadGist: () ->
    gists = new Gists {
      token: gistToken
    }
  saveGistInfo: (newGistToken, newGistID) ->
    localStorage.setItem 'gistID', newGistID ? null
    localStorage.setItem 'gistToken', newGistToken
    gistID = localStorage.getItem 'gistID'
    gistToken = localStorage.getItem 'gistToken'
  isLoaded: () ->
    gists?
  hasEnoughInfo: () ->
    gistID? && gistToken?
  pull: (cb) ->
    if gistID
      gists.get gistID
      .then (res) ->
        content = res.body.files.movies.content
        cb JSON.parse(content)
    else
      cb(null)
  push: (movies) ->
    if !gistID
      gists.create {
        description: 'MovieListDB'
        files:
          movies:
            content: JSON.stringify(movies)
      }
      .then (res) ->
        gistID = res.body.id
        localStorage.setItem 'gistID', gistID
    else
      gists.edit gistID, {
        description: 'MovieListDB'
        files:
          movies:
            filename: 'movies'
            content: JSON.stringify(movies)
    }

export default GistDB
