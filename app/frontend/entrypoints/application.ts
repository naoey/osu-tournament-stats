// To see this message, add the following to the `<head>` section in your
// views/layouts/application.html.erb
//
//    <%= vite_client_tag %>
//    <%= vite_javascript_tag 'application' %>
import { Component } from "react";
import $ from "jquery";
import ReactOnRails, { ReactComponentOrRenderFunction } from "react-on-rails";
import { humanize, toTitleCase, transform } from "@alduino/humanizer/string";

import "../stylesheets/application.scss";

console.log("Vite ⚡️ Rails");

// If using a TypeScript entrypoint file:
//     <%= vite_typescript_tag 'application' %>
//
// If you want to use .jsx or .tsx, add the extension:
//     <%= vite_javascript_tag 'application.jsx' %>

// Example: Load Rails libraries in Vite.
//
// import ActiveStorage from '@rails/activestorage'
// ActiveStorage.start()
//
// // Import all channels.
// const channels = import.meta.globEager('./**/*_channel.js')

// Example: Import a stylesheet in app/frontend/index.css
// import '~/index.css'

// startTurbo();

(window as any).$ = (window as any).jQuery = $;

// @ts-ignore
const importContext = import.meta.glob("../components/**/*.{js,ts,tsx,jsx}", { eager: true });
const componentsContext: Record<string, ReactComponentOrRenderFunction> = {};

function normaliseComponentName(name: string): string {
  return name;
}

const registeredNames = new Set<string>();

Object.entries(importContext).forEach(([filename, module]) => {
  let cleanName = filename
    .replace("../components/", "")
    .replace(/\.\w+$/, ""); // Strips the file extension

  if (cleanName.endsWith("/index"))
    cleanName = cleanName
      .replace(/\/index$/, "");

  const parts = cleanName.split("/");

  while (parts.length > 2 && parts[parts.length - 1] === parts[parts.length - 2]) {
    // Delete repeating segments
    parts.splice(parts.length - 1, 1);
  }

  // This is a dirty workaround because ReactOnRails for some ridiculous reason changes the component name format from what is
  // passed to `react_component()`. common/NavigationBar becomes Common::Navigationbar (???????????)
  cleanName = parts.map(p => humanize(transform(p, toTitleCase)))
    .join("::");

  if (!registeredNames.has(cleanName))
    componentsContext[cleanName] = Object.values(module as {})[0] as ReactComponentOrRenderFunction;
});

ReactOnRails.register(componentsContext);
