import { Controller } from "stimulus";

export class FilterController extends Controller {
  static targets = [ "query", "dateMin", "dateMax", "element", "checkbox" ];

  refine() {
    const queryValue = this.queryTarget.value.toLowerCase();
    const dateMin = this.dateMinTarget.value === "" ? null : new Date(this.dateMinTarget.value);
    const dateMax = this.dateMaxTarget.value === "" ? null : new Date(this.dateMaxTarget.value);
    this.elementTargets.forEach(target => {
      let matches = {
        query: false,
        dateMin: false,
        dateMax: false
      }

      if (target.getAttribute('data-name').toLowerCase().indexOf(queryValue) !== -1) {
        matches.query = true;
      }

      const elementDate = new Date(target.getAttribute("data-date"))
      if (dateMin == null || elementDate >= dateMin) {
        matches.dateMin = true;
      }
      if (dateMax == null || elementDate <= dateMax) {
        matches.dateMax = true;
      }

      if (matches.query && matches.dateMin && matches.dateMax) {
        target.parentNode.classList.remove('d-none');
      } else {
        target.parentNode.classList.add('d-none');
      }
    })
  }

  check(event) {
    this.checkboxTargets.forEach(target => {
      if (target.getAttribute('data-source') != event.target.getAttribute('data-source') ||
        target.checked == event.target.checked) {
        return;
      } else {
        target.click();
      }
    });
  }

  checkVisibleOnly(event) {
    this.checkboxTargets.forEach(target => {
      if (target.getAttribute('data-source') != event.target.getAttribute('data-source') ||
        target.checked == event.target.checked || target.parentNode.parentNode.classList.contains('hide')) {
        return;
      } else {
        target.click();
      }
    });
  }
}
