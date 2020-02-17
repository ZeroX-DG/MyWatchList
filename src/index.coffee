import m from 'mithril'
import app from './app.coffee'
import 'simplegrid/simple-grid.scss'
import './styles.sass'

root = document.getElementById "app"

m.mount(root, app)
