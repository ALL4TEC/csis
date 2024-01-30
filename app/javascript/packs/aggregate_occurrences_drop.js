// import { MultiDrag } from 'sortablejs';
// Cherrypick default plugins
import Sortable, { AutoScroll } from 'sortablejs/modular/sortable.core.esm.js';

const VM_DROPZONE_S = 's_agg-occ-dropzone-vm';
const VM_DROPZONE_O = 'o_agg-occ-dropzone-vm';
const WA_DROPZONE_S = 's_agg-occ-dropzone-wa';
const WA_DROPZONE_O = 'o_agg-occ-dropzone-wa';
const VM_DRAGGABLE = '.aggregate_occurrence_bloc_vm';
const WA_DRAGGABLE = '.aggregate_occurrence_bloc_wa';
const VM_GROUP = 'vm_group';
const WA_GROUP = 'wa_group';

var dzleftvm = document.getElementById(VM_DROPZONE_S);
var dzrightvm = document.getElementById(VM_DROPZONE_O);
var dzleftwa = document.getElementById(WA_DROPZONE_S);
var dzrightwa = document.getElementById(WA_DROPZONE_O);

function unCheck(itemEl) {
  var el = $(itemEl).find('input[type=checkbox]');
  if (el[0].checked) {
    el.trigger('click');
  }
  el.prop('checked', false);
  el.prop('defaultChecked', false);
  el.removeAttr('checked');
}

function check(itemEl) {
  var el = itemEl.querySelector('input[type=checkbox]');
  if (!el.checked) {
    el.click();
  }
  el.checked = true;
  el.setAttribute('checked', true);
}

if(dzleftvm !== null && dzleftwa !== null || dzrightvm !== null && dzrightwa !== null) {
  // Sortable.mount(new MultiDrag());
  Sortable.mount(new AutoScroll());
  var sortable1 = new Sortable(dzleftvm, {
    group: VM_GROUP,
    animation: 150,
    sort: false,
    draggable: VM_DRAGGABLE,
    ghostClass: 'ghost',
    forceFallback: true,
    scroll: true,
    bubbleScroll: true,
    handle: ".handle-drag",
    multiDrag: false, // Enable the plugin
    selectedClass: "sortable-selected", // Class name for selected item
    // multiDragKey: 'CTRL', // Key that must be down for items to be selected
    // Element dragging added to selected occurrences list, check for form submission
    onAdd: function (/**Event*/evt) { check(evt.item); evt.preventDefault(); }
    // onRemove: function (/**Event*/evt) { unCheck(evt.item); evt.preventDefault(); }
  });
  var sortable2 = new Sortable(dzrightvm, {
    group: VM_GROUP, // set both lists to same group
    animation: 150,
    sort: false,
    draggable: VM_DRAGGABLE,
    ghostClass: 'ghost',
    forceFallback: true,
    scroll: true,
    bubbleScroll: true,
    handle: ".handle-drag",
    multiDrag: false, // Enable the plugin
    selectedClass: "sortable-selected", // Class name for selected item
    // multiDragKey: 'CTRL', // Key that must be down for items to be selected
    // Element dragging added to unselected occurrences list, uncheck for form submission
    onAdd: function (/**Event*/evt) { unCheck(evt.item); evt.preventDefault(); }
    // onRemove: function (/**Event*/evt) { check(evt.item); evt.preventDefault(); }
  });
  var sortable3 = new Sortable(dzleftwa, {
    group: WA_GROUP,
    animation: 150,
    sort: false,
    draggable: WA_DRAGGABLE,
    ghostClass: 'ghost',
    forceFallback: true,
    scroll: true,
    bubbleScroll: true,
    handle: ".handle-drag",
    multiDrag: false, // Enable the plugin
    selectedClass: "sortable-selected", // Class name for selected item
    // multiDragKey: 'CTRL', // Key that must be down for items to be selected
    // Element dragging added to selected occurrences list, check for form submission
    onAdd: function (/**Event*/evt) { check(evt.item); evt.preventDefault(); }
    // onRemove: function (/**Event*/evt) { unCheck(evt.item); evt.preventDefault(); }
  });
  var sortable4 = new Sortable(dzrightwa, {
    group: WA_GROUP, // set both lists to same group
    animation: 150,
    sort: false,
    draggable: WA_DRAGGABLE,
    ghostClass: 'ghost',
    forceFallback: true,
    scroll: true,
    bubbleScroll: true,
    handle: ".handle-drag",
    multiDrag: false, // Enable the plugin
    selectedClass: "sortable-selected", // Class name for selected item
    // multiDragKey: 'CTRL', // Key that must be down for items to be selected
    // Element dragging added to unselected occurrences list, uncheck for form submission
    onAdd: function (/**Event*/evt) { unCheck(evt.item); evt.preventDefault(); }
    // onRemove: function (/**Event*/evt) { check(evt.item); evt.preventDefault(); }
  });
  
  // $(`#${VM_DROPZONE_S}`).find(VM_DRAGGABLE).on('dragstart', function(event) { sortable1._prepareDragStart(event); sortable1._onDragStart(event)});
  // $(`#${VM_DROPZONE_O}`).find(VM_DRAGGABLE).on('dragstart', function(event) { sortable2._prepareDragStart(event); sortable2._onDragStart(event)});
  // $(`#${VM_DROPZONE_S}`).find(VM_DRAGGABLE).on('select', function(event) { sortable1._prepareDragStart(event); sortable1.utils.select(event);});
  // $(`#${VM_DROPZONE_O}`).find(VM_DRAGGABLE).on('select', function(event) { sortable1._prepareDragStart(event); sortable2.utils.select(event);});
  // $(`#${VM_DROPZONE_S}`).find(VM_DRAGGABLE).on('deselect', function(event) { sortable1.utils.deselect(event);});
  // $(`#${VM_DROPZONE_O}`).find(VM_DRAGGABLE).on('deselect', function(event) { sortable2.utils.deselect(event);});
  // $(`#${WA_DROPZONE_S}`).find(WA_DRAGGABLE).on('dragstart', function(event) { sortable3._prepareDragStart(event); sortable3._onDragStart(event)});
  // $(`#${WA_DROPZONE_O}`).find(WA_DRAGGABLE).on('dragstart', function(event) { sortable4._prepareDragStart(event); sortable4._onDragStart(event)});
  // $(`#${VM_DROPZONE_S}`).on('dragover', function(event) {sortable1._onDragOver(event)});
  // $(`#${VM_DROPZONE_S}`).on('drop', function(event) {sortable1._onDrop(event)});
  // $(`#${VM_DROPZONE_O}`).on('dragover', function(event) {sortable2._onDragOver(event)});
  // $(`#${VM_DROPZONE_O}`).on('drop', function(event) {sortable2._onDrop(event)});
  // $(`#${WA_DROPZONE_S}`).on('dragover', function(event) {sortable3._onDragOver(event)});
  // $(`#${WA_DROPZONE_S}`).on('drop', function(event) {sortable3._onDrop(event)});
  // $(`#${WA_DROPZONE_O}`).on('dragover', function(event) {sortable4._onDragOver(event)});
  // $(`#${WA_DROPZONE_O}`).on('drop', function(event) {sortable4._onDrop(event)});

  // On supprime les listes d'occurrences non sélectionnées pour éviter que le form envoie
  // des occurrences non souhaitées...
  $('.drop-form-btn').on('click', function(event) {
    let dropzoneVm = document.getElementById(VM_DROPZONE_O);
    dropzoneVm.parentNode.removeChild(dropzoneVm);
    let dropzoneWa = document.getElementById(WA_DROPZONE_O);
    dropzoneWa.parentNode.removeChild(dropzoneWa);
    }
  );

  console.log('aggregate_occurencies_drop loaded!');
}
