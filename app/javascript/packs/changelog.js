import { callModal, setModalTitleAndContent } from "./ajax_modal";

const CHANGELOG_BTN = '.changelog-btn';

$(CHANGELOG_BTN).on('click', function() {
  getHistory();
});

function handleSuccess(data) {
  setModalTitleAndContent('CHANGELOG', data.html);
}

function getHistory() {
  callModal("/changelog", 'GET', handleSuccess);
}
