import { callModal, setModalTitleAndContent } from "./ajax_modal";

const OCCURENCE_BTN = '.occurrence-btn';

// When we use $('.whois-btn').click() to register an event handler
// it adds the handler to only those elements which exists in the dom when the code was executed
// So we need to use delegation based event handlers here
$('main').on('click', OCCURENCE_BTN, function() {
  fetchOccurrence(this.dataset.type, this.dataset.scan, this.dataset.occurrence);
});

function handleSuccess(data) {
  setModalTitleAndContent(data.title, data.html, data.titleBgColor);
}

function fetchOccurrence(type, scan_id, occurrence_id) {
  callModal(`/${type}_scans/${scan_id}/occurrences/${occurrence_id}`, 'GET', handleSuccess);
}
