import m from 'mithril'
import './search-bar.sass'

export default () ->
  view: (vnode) ->
    { onchange } = vnode.attrs
    m '#search-bar', [
      m 'i.fa.fa-search#search-icon'
      m 'input#search-box', {
        oninput: onchange,
        placeholder: 'Search movie...'
      }
    ]
