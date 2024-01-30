import "trix";
import "@rails/actiontext";
import Rails from "@rails/ujs";

const NOTE_SAVE_BTN = '#note-save-btn';
const NONE = 'd-none';

function saveForm() {
  // Display saving spinner
  $(NOTE_SAVE_BTN).removeClass(NONE);
  // Global form containing title and content
  var myForm = document.getElementById('edit_note');
  var fd = new FormData(myForm);

  Rails.ajax({
      type: "PUT",
      url: '/notes',
      dataType: "json",
      data: fd,
      success: function(data) {
        console.log('auto saved ...');
        $(NOTE_SAVE_BTN + ' .checked').removeClass(NONE);
        $(NOTE_SAVE_BTN + ' .spinner-load').addClass(NONE);
        //hide saving spinner
        setTimeout(() => {
          $(NOTE_SAVE_BTN + ' .checked').addClass(NONE);
          $(NOTE_SAVE_BTN + ' .spinner-load').removeClass(NONE);
          $(NOTE_SAVE_BTN).addClass(NONE);
        }, 1000);

      },
      error: function(data) {
        alert('An error occured...Please retry or contact support');
        $(NOTE_SAVE_BTN + ' .error').removeClass(NONE);
        $(NOTE_SAVE_BTN + ' .spinner-load').addClass(NONE);
        //hide saving spinner
        setTimeout(() => {
          $(NOTE_SAVE_BTN + ' .error').addClass(NONE);
          $(NOTE_SAVE_BTN + ' .spinner-load').removeClass(NONE);
          $(NOTE_SAVE_BTN).addClass(NONE);
        }, 1000);
      }
  });
}

document.addEventListener("trix-focus", function(event) {
  event.target.toolbarElement.style.display = "block";
});

$('#note_title').on('blur', function() {
  saveForm();
});

document.addEventListener("trix-blur", function(event) {
  saveForm();
  event.target.toolbarElement.style.display = "none";
});
