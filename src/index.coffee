import m from 'mithril'
import app from './app.coffee'
import './styles.sass'

root = document.getElementById "app"

m.mount(root, app)
