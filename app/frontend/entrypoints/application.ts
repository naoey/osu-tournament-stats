// To see this message, add the following to the `<head>` section in your
// views/layouts/application.html.erb
//
//    <%= vite_client_tag %>
//    <%= vite_javascript_tag 'application' %>
console.log('Vite ⚡️ Rails')

// If using a TypeScript entrypoint file:
//     <%= vite_typescript_tag 'application' %>
//
// If you want to use .jsx or .tsx, add the extension:
//     <%= vite_javascript_tag 'application.jsx' %>

// Example: Load Rails libraries in Vite.
//
// import * as Turbo from '@hotwired/turbo'
// Turbo.start()
//
// import ActiveStorage from '@rails/activestorage'
// ActiveStorage.start()
//
// // Import all channels.
// const channels = import.meta.globEager('./**/*_channel.js')

// Example: Import a stylesheet in app/frontend/index.css
// import '~/index.css'

import $ from 'jquery';
import ReactRailsUJS from 'react_ujs';

import "../stylesheets/application.scss";

(window as any).$ = (window as any).jQuery = $;

export const reactUJSConstructor = function (reqCtx) {
  const fromRequireContext = function (reqCtx) {
    return function (className) {
      const parts = className.split(".");
      const filename = className.split('.').join('/')
      const keys = parts;
      // Load the module:
      const componentPath = Object.keys(reqCtx).find((path => path.search(filename) > 0));

      let component = reqCtx[componentPath];
      component = Object.values(component)[0];
      return component;
    }
  }

  const fromCtx = fromRequireContext(reqCtx);
  return function (className) {
    let component;
    try {
      // `require` will raise an error if this className isn't found:
      component = fromCtx(className);
    } catch (firstErr) {
      console.error(firstErr);
    }
    return component;
  }
}

const importContext = import.meta.glob("../components/**/*.{js,ts,jsx,tsx}", { eager: true });
ReactRailsUJS.getConstructor = reactUJSConstructor(importContext);
