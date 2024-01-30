import { callModal, setModalTitleAndContent } from "./ajax_modal";
import { BTN_CLIP, copyToClipboard } from "./clip";

const PUB_KEY_BTN = '.pub_key-btn';

$('body').on('click', BTN_CLIP, copyToClipboard);

$('main').on('click', PUB_KEY_BTN, function() {
  getPublicKey(this.dataset.user_id);
});

function handleSuccess(data) {
  setModalTitleAndContent(data.title, data.html);
}

function getPublicKey(user_id) {
  callModal(`/users/${user_id}/public_key`, 'GET', handleSuccess);
}
