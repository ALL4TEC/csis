import * as bootstrap from 'bootstrap/dist/js/bootstrap.bundle.js';
import * as material from "./material";
import "./filters";
import * as collapse from "./collapse_common";
import "./collapse_handler";
import {hideElement, showElement} from "./common";
import './ajax_modal';
import "./changelog";

window.bootstrap = bootstrap;
// For bootstrap-select...
window.Dropdown = bootstrap.Dropdown;

const OVERLAY = '.overlay';
const AGGREGATES_ID = '#aggregates';

function refreshTooltips() {
  // Enable all tooltips
  var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
  tooltipTriggerList.map(function (tooltipTriggerEl) {
    return new bootstrap.Tooltip(tooltipTriggerEl);
  });
}

function refreshToastsList() {
  // Enable toasts
  var toastElList = [].slice.call(document.querySelectorAll('.toast'));
  toastElList.map(function (toastEl) {
    return new bootstrap.Toast(toastEl);
  });
}

$(function() {
  collapse.getShownCollapseFromLS();
  $(material.FORM_INPUT).each(material.handleFormControl);
  refreshTooltips();
  refreshToastsList();
  // Manage sidebar
  $('.burger-btn').on('click', function () {
    $('#sidebar').toggleClass('active');
    $(this).toggleClass('active');
  });
});

// Après chaque ajout de contenu, on rafraichit les composants bootstrap pour pouvoir
// les utiliser
$(document).on('cable-ready:after-prepend', function() {
  refreshToastsList();
  refreshTooltips();
});

$(document).on('cable_ready:after-morph', function() {
  console.log('cable_ready:after_morph');
});

$(document).on('stimulus-reflex:ready', function() {
  console.log('stimulus-reflex:ready');
});

$(document).on('turbo:render', function() {
  $(AGGREGATES_ID).hide();
});

$(document).on('turbo:load', function() {
  collapse.loadCollapse();
  $(AGGREGATES_ID).show();
});

$(document).on("turbo:request-end", function(){
  hideElement($(OVERLAY));
});

$(document).on("turbo:click", function(){
  showElement($(OVERLAY));
});

console.log('Bootstrap loaded !');
