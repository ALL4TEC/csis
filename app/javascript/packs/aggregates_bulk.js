import Rails from "@rails/ujs";

const MERGE_AGGREGATES_BTN = '.merge-aggregates';
const DUPLICATE_AGGREGATES_BTN = '#duplicate-aggregates-btn';
const DUPLICATE_AGGREGATES_RESPONSE = '#duplicate-aggregates-response';
const DUPLICATE_SELECTED_REPORTS = '#duplicate-reports-select :selected';
const CHECKED_AGGREGATES = 'input[name="aggregate[aggregates][]"]:checked';
const CHECKED_OCCURRENCES = 'input[name="aggregate[occurrences][]"]:checked';
const DELETE_AGGREGATES_BTN = '#delete-aggregates-btn';
const DELETE_AGGREGATES_RESPONSE = '#delete-aggregates-response';

$(MERGE_AGGREGATES_BTN).on('click', function() {
  mergeAggregates($(this));
});

$(DUPLICATE_AGGREGATES_BTN).on('click', function() {
  duplicateAggregates();
});

$(DELETE_AGGREGATES_BTN).on('click', function() {
  deleteAggregates($(this));
});

function findAllCheckedAggregates() {
  return $(CHECKED_AGGREGATES).map(
    function() {
      return this.value;
    }
  ).get();
}

function findAllCheckedOccurrences() {
  return $(CHECKED_OCCURRENCES).map(
    function() {
      return { aggregate_id: this.dataset.aggregate, occurrence_id: this.value };
    }
  ).get();
}

function findAllSelectedReports() {
  return $(DUPLICATE_SELECTED_REPORTS).map(
    function() {
      return this.value
    }
  ).get();
}

function mergeAggregates(el) {
  const aggregates_ids = findAllCheckedAggregates();
  const occurrences_data = findAllCheckedOccurrences();
  mergeDataIntoAggregate(el.data('target'), aggregates_ids, occurrences_data);
}

function duplicateAggregates() {
  const aggregates_ids = findAllCheckedAggregates();
  const reports_ids = findAllSelectedReports();
  duplicateAggregatesIntoReports(reports_ids, aggregates_ids);
}

function deleteAggregates(el) {
  const aggregates_ids = findAllCheckedAggregates();
  deleteAggregatesFromReport(el.data('source'), aggregates_ids);
}

/**
 * @param {String} aggregate_id Target aggregate
 * @param {Array<String>} aggregates_ids Source aggregates to move
 * @param {Array<Map<String, String>>} occurrences_data Source occurrences to move
 */
 function mergeDataIntoAggregate(aggregate_id, aggregates_ids, occurrences_data) {
  var fd = new FormData();
  fd.append("aggregate_ids", aggregates_ids);
  fd.append("occurrences_data", JSON.stringify(occurrences_data));

  Rails.ajax({
    url: `/aggregates/${aggregate_id}/merge`,
    type: "PUT",
    dataType: "json",
    data: fd,
    success: function(data) {
      location.reload();
    },
    error: function(data) {alert('An error occured... Please refresh')}
  })
}

/**
 * @param {Array<String>} reports_ids Target reports
 * @param {Array<String>} aggregates_ids Source aggregates to duplicate
 */
function duplicateAggregatesIntoReports(reports_ids, aggregates_ids) {
  var fd = new FormData();
  fd.append("aggregate_ids", aggregates_ids);
  fd.append("report_ids", reports_ids);

  Rails.ajax({
    url: `/aggregates/duplicate`,
    type: "POST",
    dataType: "json",
    data: fd,
    success: function(data) {
      if (data.status == 'error') {
        displayError($(DUPLICATE_AGGREGATES_RESPONSE)[0], data.message);
      } else {
        displayOk($(DUPLICATE_AGGREGATES_RESPONSE)[0]);
      }
    },
    error: function(data) {alert('An error occured... Please refresh')}
  })
}

function deleteAggregatesFromReport(report_id, aggregates_ids) {
  var fd = new FormData();
  fd.append("aggregate_ids", aggregates_ids);

  Rails.ajax({
    url: `/reports/${report_id}/aggregates`,
    type: "DELETE",
    dataType: "json",
    data: fd,
    success: function(data) {
      if (data.status == 'error') {
        displayError($(DELETE_AGGREGATES_RESPONSE)[0], data.message);
      } else {
        displayOk($(DELETE_AGGREGATES_RESPONSE)[0]);
        location.reload();
      }
    },
    error: function(data) {alert('An error occured... Please refresh')}
  })
}

function displayError(el, message) {
  el.classList.remove('d-none');
  el.classList.add('text-danger');
  el.querySelector('span').textContent = message;
  el.querySelector('i').textContent = 'error';
}

function displayOk(el) {
  el.classList.remove('d-none');
  el.classList.add('text-success');
  el.querySelector('i').textContent = 'check';
}
