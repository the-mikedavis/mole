import sass from "../css/master.sass"

import "phoenix_html"

import socket from "./socket"

import form_feedback from './form_feedback'
if (document.querySelector('form')) form_feedback()
