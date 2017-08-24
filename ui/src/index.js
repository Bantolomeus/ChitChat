import './favicon-300.png';

// Load all style sheets
import 'animate.css/animate.css';
import 'material-components-web/dist/material-components-web.css'
import './index.css';

// Import the application from ELM
import * as Elm from './Main.elm';
export const app = Elm.Main.embed(document.getElementById('main'));
