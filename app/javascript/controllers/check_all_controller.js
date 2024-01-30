import { Controller } from "stimulus";

export class CheckAllController extends Controller {
  static targets = [ "element", "checkbox" ];

  checkAll(event) {
    this.checkboxTargets.forEach(target => {
      if (!target.getAttribute('data-source').includes(event.target.getAttribute('data-source')) ||
        target.checked == event.target.checked) {
        return;
      } else {
        target.click();
      }
    });
  }
}
