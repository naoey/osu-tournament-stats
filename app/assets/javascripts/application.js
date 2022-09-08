// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require activestorage
//= require turbolinks
//= require_tree .

import '../../../node_modules/antd/dist/antd.compact.css';
import '../../assets/stylesheets/application.scss';

var componentRequireContext = require.context("./components", true)
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