import { showElement, hideElement, activateElement, isActive, deactivateElements } from "./common";

// Lors du click sur les badges de count d'aggrégats par sévérité ou visibilité,
// on cache ou montre les aggrégats en relation

const FILTER_ACTIONS = '.filter-actions';
const SHOW_SEVERITIES = 'show-severities';

$(FILTER_ACTIONS).on('click', function() {
    filterActions($(this));
});

/** activate element and deactivate others */
function addActiveClass(element, parent) {
    // If element already is activated, no need to re loop for deactivation
    if (isActive(element)) {
        // DO NOTHING
    } else {
        deactivateElements($(FILTER_ACTIONS + '[parent=' + parent + ']'));
        activateElement(element);
    }
}

/** Click on checkAll checkbox if checked to uncheck all actions */
function uncheckAllActions() {
    let checkAll = $('#check-all:checked');
    if(checkAll !== undefined) {
        checkAll.trigger('click');
    }
}

/*
* Filter actions function of severity
*/
function filterActions(element) {
    let severity = '';
    if((parent = element.attr('parent')) !== undefined) {
        addActiveClass(element, parent);
        if (element.attr('show-all') == 'true') {
            showAllActions();
        } else if ((severity = element.attr(SHOW_SEVERITIES)) !== undefined) {
            // WE MUST UNCHECK ALL ELEMENTS BEFORE APPLYING FILTER
            // AS THIS COULD LEAD TO UNWANTED BEHAVIOUR LIKE SENDING ALL THE FORM CHECKBOXES
            // WHEN THINKING OF ONLY SENDING VISIBLE ONES
            uncheckAllActions();
            showActionsBySeverity(severity);
        } else {
            console.log('Missing action filter parameters for ' + element);
        }
    } else {
        console.log('Missing action parent to filter for ' + element);
    }
}

function getActionsArray() {
    return $('.actions');
}

function showAllActions() {
    let actions = getActionsArray();
    actions.each( function() {
        showElement($(this)) 
    });
}

function showActionsBySeverity(severity) {
    let actions = getActionsArray();
    actions.each( function() {
        if($(this).find('.severity')[0].dataset['severity'] == severity) {
            showElement($(this));
        } else {
            hideElement($(this));
        }
    });
}
