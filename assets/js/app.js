import 'jquery'
import 'bootstrap'
import 'bootstrap/dist/css/bootstrap.min.css'
import css from "../css/app.css"
import sass from "../css/master.sass"

import "phoenix_html"

import socket from "./socket"

import form_feedback from './form_feedback'
if (document.querySelector('form')) form_feedback()

$(document).ready(function() {
  $('li.active').removeClass('active')
  $('a[href="' + location.pathname + '"]').closest('li').addClass('active')
})
