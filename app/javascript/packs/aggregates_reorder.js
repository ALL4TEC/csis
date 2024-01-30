// Cherrypick default plugins
import Sortable, { AutoScroll } from 'sortablejs/modular/sortable.core.esm.js';
import Rails from "@rails/ujs";

function beforeCall(el) {
  // Remove list icon
  el.querySelector('.material-icons').classList.add('d-none');
  // Display spinner
  el.querySelector('.spinner-border').classList.remove('d-none');
}

function afterCall(el) {
  // Remove spinner
  el.querySelector('.spinner-border').classList.add('d-none');
  // Change bg-primary to bg-secondary
  el.classList.remove('bg-primary');
  el.classList.add('bg-secondary');
  // Remove icon animation
  el.querySelector('.material-icons').classList.remove('d-none', 'i_scale_infinite', 'bg-primary');
}

/**
 * @param {ReportId} report_id
 * @param {AggregateKind} kind
 * @param {List of aggregates ids} list
 */
function reorderReportAggregates(report_id, kind, list, el) {
  var fd = new FormData();
  fd.append("kind", kind);
  fd.append("aggregates_data", JSON.stringify(list));

  Rails.ajax({
    url: `/reports/${report_id}/aggregates/reorder`,
    type: "POST",
    dataType: "json",
    data: fd,
    success: function(data) {
      // On boucle sur la liste des aggrégats et on met à jour en fonction des data.
      // Si les data ne sont pas en accord, on saura qu'il y a une erreur.
      Rails.$('.aggregate-bloc-' + kind).forEach(function(element) {
          // On récupère l'id de l'aggrégat
          let aggId = element.id;
          // On récupère l'index de l'aggrégat correspondant dans la liste de la réponse
          let aggPosition = data.indexOf(aggId);
          // On set la position dans le HTML
          element.querySelector('.' + kind + '-rank').innerHTML = aggPosition + 1;
        }
      );
      afterCall(el);
    },
    error: function(data) {alert('An error occured... Please refresh')}
  })
}

/**
 * Handle click on a reorder button
 * @param {*} el clicked button
 * @param {*} kind 
 */
function handleClickOnReorderBtn(el, kind) {
  beforeCall(el);
  const REPORT_ID_REGEX = /reports\/(.*)\/aggregates/;
  const report_id = window.location.toString().match(REPORT_ID_REGEX)[1]; // Premier capturing group
  let movedAggregates = [];
  $('.aggregate-bloc-' + kind).each(function (index) {
    let newRank = index + 1;
    if (parseInt(this.querySelector('.' + kind + '-rank').innerText, 10) !== newRank) {
      movedAggregates.push({id: this.id, position: newRank});
    }
  });
  // call AJAX to save list order
  reorderReportAggregates(report_id, kind, movedAggregates, el);
}

/*** Aggregates orders ***/
const ORDER_DROPZONE = 'aggregates_order';
const ORDER_DRAGGABLE = '.agg-order';
const SAVE_ALL_RANKS = '#btn-save-all-ranks';
var dzo = document.getElementById(ORDER_DROPZONE);
if(dzo !== undefined) {
  new Sortable(dzo, {
    animation: 150,
    handle: '.handle-drag',
    draggable: ORDER_DRAGGABLE,
    ghostClass: 'ghost',
    forceFallback: true,
    sort: true
  });
}

$(SAVE_ALL_RANKS).on('click', function() {
  $(PARENT_APP + REORDER_BTN).trigger('click');
  $(PARENT_SYS + REORDER_BTN).trigger('click');
  this.querySelector('.material-icons').classList.remove('i_scale_infinite');
});

/*** Aggregates ranks ***/
const ORG_DROPZONE = 'aggregateOrg';
const VM_DROPZONE = 'aggregateSys';
const WA_DROPZONE = 'aggregateApp';
const PARENT_ORG = '#' + ORG_DROPZONE;
const PARENT_SYS = '#' + VM_DROPZONE;
const PARENT_APP = '#' + WA_DROPZONE;
const REORDER_BTN = '-reorder-btn';
const ORG_DRAGGABLE = '.aggregate-bloc-organizational';
const VM_DRAGGABLE = '.aggregate-bloc-system';
const WA_DRAGGABLE = '.aggregate-bloc-applicative';

var dzorg = document.getElementById(ORG_DROPZONE);
var dzvm = document.getElementById(VM_DROPZONE);
var dzwa = document.getElementById(WA_DROPZONE);

if(dzorg !== undefined || dzvm !== undefined || dzwa !== undefined) {
  Sortable.mount(new AutoScroll());

  /*** Orders ***/
  $(PARENT_ORG + REORDER_BTN).on('click', function() {
    handleClickOnReorderBtn(this, 'organizational');
  });
  $(PARENT_APP + REORDER_BTN).on('click', function() {
    handleClickOnReorderBtn(this, 'applicative');
  });
  $(PARENT_SYS + REORDER_BTN).on('click', function() {
    handleClickOnReorderBtn(this, 'system');
  });

  /*** Ranks ***/
  if(dzorg !== null) {
    var sortable0 = new Sortable(dzorg, {
      animation: 150,
      draggable: ORG_DRAGGABLE,
      ghostClass: 'bg-primary',
      forceFallback: true,
      scroll: true,
      bubbleScroll: true,
      selectedClass: "sortable-selected", // Class name for selected item
      onChange: function(evt) {
        $(PARENT_ORG + REORDER_BTN).find('.material-icons').addClass('i_scale_infinite bg-primary');
      }
    });
    $(`#${ORG_DROPZONE}`).find(ORG_DRAGGABLE).on('dragstart', function(event) { sortable0._prepareDragStart(event); sortable0._onDragStart(event)});
    $(`#${ORG_DROPZONE}`).on('dragover', function(event) {sortable0._onDragOver(event)});
    $(`#${ORG_DROPZONE}`).on('drop', function(event) {sortable0._onDrop(event)});
  }

  if(dzvm !== null) {
    var sortable1 = new Sortable(dzvm, {
      animation: 150,
      draggable: VM_DRAGGABLE,
      ghostClass: 'bg-primary',
      forceFallback: true,
      scroll: true,
      bubbleScroll: true,
      selectedClass: "sortable-selected", // Class name for selected item
      onChange: function(evt) {
        $(PARENT_SYS + REORDER_BTN).find('.material-icons').addClass('i_scale_infinite bg-primary');
      }
    });
    $(`#${VM_DROPZONE}`).find(VM_DRAGGABLE).on('dragstart', function(event) { sortable1._prepareDragStart(event); sortable1._onDragStart(event)});
    $(`#${VM_DROPZONE}`).on('dragover', function(event) {sortable1._onDragOver(event)});
    $(`#${VM_DROPZONE}`).on('drop', function(event) {sortable1._onDrop(event)});
  }

  if(dzwa !== null) {
    var sortable2 = new Sortable(dzwa, {
      animation: 150,
      draggable: WA_DRAGGABLE,
      ghostClass: 'bg-primary',
      forceFallback: true,
      scroll: true,
      bubbleScroll: true,
      selectedClass: "sortable-selected", // Class name for selected item
      onChange: function(evt) {
        $(PARENT_APP + REORDER_BTN).find('.material-icons').addClass('i_scale_infinite bg-primary');
      }
    });
    $(`#${WA_DROPZONE}`).find(WA_DRAGGABLE).on('dragstart', function(event) { sortable2._prepareDragStart(event); sortable2._onDragStart(event)});
    $(`#${WA_DROPZONE}`).on('dragover', function(event) {sortable2._onDragOver(event)});
    $(`#${WA_DROPZONE}`).on('drop', function(event) {sortable2._onDrop(event)});
  }

  console.log('aggregates_drop loaded!');
}
