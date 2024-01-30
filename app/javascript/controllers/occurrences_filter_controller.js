import { Controller } from "stimulus";

export class OccurrencesFilterController extends Controller {
  static targets = [ "id", "title", "severity", "status", "kind", "element" ];

  refine() {
    const idValue = this.idTarget.value.toLowerCase();
    const titleValue = this.titleTarget.value.toLowerCase();
    const severityValue = this.severityTarget.value.toLowerCase();
    const statusValue = this.statusTarget.value.toLowerCase();
    const kindValue = this.kindTarget.value.toLowerCase();
    this.elementTargets.forEach(target => {
      let matches = {
        id: false,
        title: false,
        severity: false,
        kind: false,
        status: false
      }
      const allEmptyValues = idValue.length == 0 && titleValue.length == 0 && severityValue.length == 0 && kindValue.length == 0 && statusValue.length == 0

      if (idValue.length == 0 || idValue.length > 0 && target.querySelector('.qid').textContent.toLowerCase().indexOf(idValue) !== -1) {
        matches.id = true;
      }
      if (titleValue.length == 0 || titleValue.length > 0 && target.querySelector('.btn-card').getAttribute('title').toLowerCase().indexOf(titleValue) !== -1) {
        matches.title = true;
      }
      if (severityValue.length == 0 || severityValue.length > 0 && target.getAttribute('data-severity').toLowerCase() == severityValue) {
        matches.severity = true;
      }
      if (kindValue.length == 0 || kindValue.length > 0 && target.getAttribute('data-kind').toLowerCase() == kindValue) {
        matches.kind = true;
      }
      if (statusValue.length == 0 || statusValue.length > 0 && target.getAttribute('data-status').toLowerCase() == statusValue) {
        matches.status = true;
      }

      if (allEmptyValues || (matches.id && matches.title && matches.severity && matches.kind && matches.status)) {
        target.classList.remove('d-none');
        target.classList.add('d-flex');
      } else {
        target.classList.add('d-none');
        target.classList.remove('d-flex');
      }
    })
  }

  moveFiltered(event) {
    let columnKind = event.target.getAttribute('data-id-prefix');
    let moveToColumn = columnKind == 's_' ? 'o_' : 's_';
    const aggKinds = ['vm', 'wa'];
    aggKinds.forEach(aggKind => {
      let dzBloc = $(`#${columnKind}agg-occ-dropzone-${aggKind}`);
      let occurrences = dzBloc.find(`.aggregate_occurrence_bloc_${aggKind}`);
      occurrences.each(function() {
        let occ = this;
        if (occ.classList.contains('d-none')) {
          return;
        } else {
          let targetDzBloc = document.getElementById(`${moveToColumn}agg-occ-dropzone-${aggKind}`);
          let checkInput = occ.querySelector('input[type=checkbox]');
          // Move to other column dzBloc
          targetDzBloc.appendChild(occ);
          // Toggle check
          checkInput.click();
        }
      });
    });
  }

  addFilteredScopes(event) {
    // Auto handle scope
    let scopeEl = document.getElementById('aggregate_scope');
    this.elementTargets.forEach(target => {
      if (!target.classList.contains('d-none')) {
        const target_scope = target.querySelector('.scope').textContent;
        this.updateElement(scopeEl, target_scope);
      }
    });
    // Suppression des doublons
    let sortedAryContent = Array.from(new Set(scopeEl.value.split('\n'))).sort();
    // Clean scopeEl
    scopeEl.value = '';
    sortedAryContent.forEach(element => this.updateElement(scopeEl, element));
    // Tri alphabétique
    autosize.update(scopeEl);
  }

  addTitle(event) {
    let title_el = document.getElementById('aggregate_title');
    const target_title = event.srcElement.parentNode.getAttribute('data-title');
    title_el.setAttribute('value', target_title);
    title_el.value = target_title;
    title_el.parentNode.querySelector('label.form-control-label').classList.add('active');
  }

  addDescription(event) {
    let desc_el = document.getElementById('aggregate_description');
    const target_desc = event.srcElement.parentNode.getAttribute('data-description');
    this.updateElement(desc_el, target_desc);
    autosize.update(desc_el);
  }

  addSolution(event) {
    let solution_el = document.getElementById('aggregate_solution');
    const target_solution = event.srcElement.parentNode.getAttribute('data-solution');
    this.updateElement(solution_el, target_solution);
    autosize.update(solution_el);
  }

  updateElement(el, value) {
    if (el.value.length > 0) {
      el.value += '\n' + value
    } else {
      el.value = value
    }
    el.parentNode.querySelector('label.form-control-label').classList.add('active');
  }
}
