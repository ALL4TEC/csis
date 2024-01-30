/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb
import Rails from "@rails/ujs";
import "@hotwired/turbo-rails";

import "../stylesheets/application";
import "channels";
import "controllers";

Rails.start();
// Pour rendre disponibles certaines variables globalement dans l'application et donc utilisables dans les scripts du répertoire
// app/views il suffit de les rendre globales comme suit
global.Rails = Rails;
global.$ = $;

console.log('Application loaded!');
