// To reference this file, add <%= javascript_pack_tag 'report_form' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb
import { Application } from "stimulus";
import { CheckAllController } from "../controllers/check_all_controller";

const application = Application.start();
application.register('checker', CheckAllController);

console.log('Stimulus loaded !');

const KINDS_ID = "#kinds_0";

$(KINDS_ID).on("click", function() {
  // si checked
  let checked = $(this).is(":checked");
  if (checked) {
    // On decoche+disable les 3 autres options
    for (let i=1;i<4;i++) {
      $(`#kinds_${i}`).removeAttr('checked');
      $(`#kinds_${i}`).attr('disabled', true);
    }
  } else {
    // On coche+enable les 3 autres options
    for (let i=1;i<4;i++) {
      $(`#kinds_${i}`).attr('checked', true);
      $(`#kinds_${i}`).attr('disabled', false);
    }
  }
});
