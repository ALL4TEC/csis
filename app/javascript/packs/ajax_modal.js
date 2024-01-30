import { dNoneElement, displayElement } from './common';
import { call } from './http';

const MODAL_TITLE = '#ajax-modal-title';
const MODAL_TITLE_LOADING = '#ajax-modal-title-loading';
const MODAL_CONTENT = '#ajax-modal-content';
const MODAL_CONTENT_LOADING = '#ajax-modal-content-loading';

$('#ajax-modal').on('hide.bs.modal', function (e) {
  // Hide data if present for next load
  dNoneElement($(MODAL_TITLE));
  dNoneElement($(MODAL_CONTENT));
  // Display loading data
  displayElement($(MODAL_TITLE_LOADING));
  displayElement($(MODAL_CONTENT_LOADING));
});

export function setModalTitleAndContent(title, content, titleBgColor = 'btn-primary') {
  // Hide loading data
  dNoneElement($(MODAL_TITLE_LOADING));
  dNoneElement($(MODAL_CONTENT_LOADING));
  // Display data
  displayElement($(MODAL_TITLE));
  displayElement($(MODAL_CONTENT));
  // Set data
  $(MODAL_TITLE).html(title);
  $(MODAL_CONTENT).html(content);

  // Replace modal header bg-color
  $(MODAL_TITLE).parent().removeClass(function (index, className) {
    return (className.match (/(^|\s)btn-\S+/g) || []).join(' ');
  });
  $(MODAL_TITLE).parent().addClass(titleBgColor);
}

export function handleError(data) {
  if( data.error != undefined) {
    setModalTitleAndContent('ERROR', data.error);
  } else {
    setModalTitleAndContent('ERROR', data);
  }
}

// Must Implement handleSuccess
export function callModal(url, method, handleSuccessFunction) {
  call(url, method, 'json', null, null, handleSuccessFunction, handleError);
}

export function callModalWithData(url, method, formData, handleSuccessFunction) {
  call(url, method, 'json', formData, null, handleSuccessFunction, handleError);
}
