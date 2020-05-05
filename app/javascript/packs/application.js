/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

// Support component names relative to this directory:
import '../../../node_modules/antd/dist/antd.compact.css';

import '../../assets/stylesheets/application.scss';

var componentRequireContext = require.context("components", true)
var ReactRailsUJS = require("react_ujs")
ReactRailsUJS.useContext(componentRequireContext)

$(document).on('user.session_expired', function() {
  window.location.href = "/login";
});

document.addEventListener("DOMContentLoaded", function() {
  var userDataContainer = document.getElementById('current-user');

  if (userDataContainer && userDataContainer.dataset.currentUser) {
    window.currentUser = JSON.parse(userDataContainer.dataset.currentUser);
    window.isAuthenticated = !!window.currentUser;
  } else {
    window.currentUser = null;
    window.isAuthenticated = false;
  }
});

