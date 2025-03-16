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

const importContext = import.meta.glob("../components/**/*.{js,ts,tsx,jsx}", { eager: true });
const componentsContext = {};

Object.entries(importContext).forEach(([filename, component]) => {
  let cleanName = filename
    .replace("../components/", "")
    .replace(/\.\w+$/, ""); // Strips the file extension
  componentsContext[cleanName] = Object.values(component)[0];
});

ReactRailsUJS.getConstructor = (name) => componentsContext[name] || componentsContext[`${name}/index`];
