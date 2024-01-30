import { callModalWithData, setModalTitleAndContent } from "./ajax_modal";

const WHOIS_BTN = '.whois-btn';

// When we use $('.whois-btn').click() to register an event handler
// it adds the handler to only those elements which exists in the dom when the code was executed
// So we need to use delegation based event handlers here
$('main').on('click', WHOIS_BTN, function() {
  whois(this.dataset.whois);
});

function handleSuccess(data) {
  setModalTitleAndContent(data.title, data.html);
}

function whois(target) {
  callModalWithData('/whois', 'POST', `target=${target}`, handleSuccess);
}
