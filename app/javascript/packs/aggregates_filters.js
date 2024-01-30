import { showElement, hideElement, activateElement, isActive, deactivateElements } from "./common";

// Lors du click sur les badges de count d'aggrégats par sévérité ou visibilité,
// on cache ou montre les aggrégats en relation

const FILTER_AGGREGATE = '.filter-aggregates';
const SHOW_SEVERITIES = 'show-severities';
const SHOW_STATUSES = 'show-statuses';
const SHOW_VISIBILITY = 'show-visibility';

$(FILTER_AGGREGATE).on('click', function() {
  filterAggregates($(this));
});

/** activate element and deactivate others */
function addActiveClass(element, parent) {
  // If element already is activated, no need to re loop for deactivation
  if (isActive(element)) {
    // DO NOTHING
  } else {
    deactivateElements($(FILTER_AGGREGATE + '[parent=' + parent + ']'));
    activateElement(element);
  }
}

/*
* Filter aggregates function of severity/visibility
*/
function filterAggregates(element) {
  let severity, visibility, status, parent = '';
  if((parent = element.attr('parent')) !== undefined) {
    addActiveClass(element, parent);
    if (element.attr('show-all') == 'true') {
      showAllAggregates(parent);
    } else if ((severity = element.attr(SHOW_SEVERITIES)) !== undefined) {
      showAggregatesBySeverity(parent, severity);
    } else if ((visibility = element.attr(SHOW_VISIBILITY)) !== undefined) {
      showAggregatesByVisibility(parent, visibility);
    } else if ((status = element.attr(SHOW_STATUSES)) !== undefined) {
      showAggregatesByStatus(parent, status);
    } else {
      console.log('Missing aggregates filter parameters for ' + element);
    }
    openParent(parent); // At the end, as content is defined
  } else {
    console.log('Missing aggregate parent to filter for ' + element);
  }
}

function openParent(parent) {
  $('#' + parent).collapse('show');
}

function getAggregatesArrayFunctionOfParentId(parent) {
  return $('div#' + parent).children('div.aggregate');
}

function showAllAggregates(parent) {
  let aggregates = getAggregatesArrayFunctionOfParentId(parent);
  aggregates.each( function() {
    showElement($(this))
  });
}

function showAggregatesBySeverity(parent, severity) {
  let aggregates = getAggregatesArrayFunctionOfParentId(parent);
  aggregates.each( function() {
    if($(this).find('.severity').text().includes(severity)) {
      showElement($(this));
    } else {
      hideElement($(this));
    }
  });
}

function showAggregatesByVisibility(parent, visibility) {
  let clazz = (visibility === '0' ? 'btn-warning' : 'btn-success');
  let aggregates = getAggregatesArrayFunctionOfParentId(parent);
  aggregates.each( function() {
    if($(this).find('.visibility').hasClass(clazz)) {
      showElement($(this));
    } else {
      hideElement($(this));
    }
  });
}

function showAggregatesByStatus(parent, status) {
  let aggregates = getAggregatesArrayFunctionOfParentId(parent);
  aggregates.each( function() {
    if($(this).find('.status').attr('title').includes(status)) {
      showElement($(this));
    } else {
      hideElement($(this));
    }
  });
}
