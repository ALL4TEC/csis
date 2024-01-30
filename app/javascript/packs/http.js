import { displayElement, dNoneElement } from "./common";

// Gestion chargement/affichage
export function beforeCall(targetId, targetSpinnerId) {
  dNoneElement($(targetId), 'flex');
  displayElement($(targetSpinnerId), 'flex');
}

// Gestion chargement/affichage
export function afterCall(targetId, targetSpinnerId) {
  dNoneElement($(targetSpinnerId), 'flex');
  displayElement($(targetId), 'flex');
}

// Makes an ajax call to url with method
export function callContentSpinner(url, method, contentId, spinnerId) {
  beforeCall(contentId, spinnerId);
  Rails.ajax({
    url: url,
    type: method,
    success: function(data) {
      afterCall(contentId, spinnerId);
    },
    error: function(data) {
      alert(`An error has occured, please refresh`);
    }
  })
}

export function call(url, method, dataType, formData, beforeMethod, afterMethod, errorMethod) {
  if(beforeMethod) {
    beforeMethod();
  }
  Rails.ajax({
    url: url,
    type: method,
    dataType: dataType,
    data: formData,
    success: function(data) {
      afterMethod(data);
    },
    error: function(data) {
      errorMethod(data);
    }
  })
}

export function fetch(url, contentId, spinnerId) {
  callContentSpinner(url, 'GET', contentId, spinnerId);
}
