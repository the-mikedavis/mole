import css from "../css/app.css"
import sass from "../css/master.sass"

import "phoenix_html"

import socket from "./socket"
import slider from "./tinder"

const slide_piece = document.getElementById('card');
if (slide_piece)
  slider(slide_piece);
