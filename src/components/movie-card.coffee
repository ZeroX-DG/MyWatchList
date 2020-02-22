import m from 'mithril'
import './movie-card.sass'

export default () ->
  view: (vnode) ->
    { title, img, year, directors, watchcount } = vnode.attrs.movie
    { onwatchclick, onremoveclick } = vnode.attrs
    m '.movie-card', [
      m ".watch-status#{if watchcount == 0 then '.no-watch' else ''}", {
        onclick: onwatchclick
      }, [
        m 'span.watch-count', [
          m 'i.fa.fa-eye', { style: 'color: white; margin-right: 10px' }
          "#{watchcount} time#{if watchcount > 1 then 's' else ''}"
        ]
        m 'i.fa.fa-eye.watch-icon'
      ]
      m 'button.remove', { onclick: onremoveclick }, m 'i.fa.fa-trash'
      m 'img.background', { src: img }
      m '.info', [
        m 'p.meta', [
          m 'span.directors', directors.slice(0, 2).join(', ')
          m 'span.year', year
        ]
        m 'h2.title', title
      ]
    ]

