import * as collapse from "./collapse_common";

const COLLAPSE_NO_SAVE_ID_INC = 'filter';
const COLLAPSE_NO_SAVE_CLASS = 'collapse_no_save';

$('.collapse').on('shown.bs.collapse', function() { 
    // Si pas d'id do nothing
    if($(this).attr('id') !== undefined) {
        let shownOnRefresh = JSON.parse(localStorage.getItem(collapse.LS_SHOWN_ON_REFRESH));

        if ($.inArray($(this).attr('id'), shownOnRefresh) == -1) {
            // Save item if no id or class specifying not to
            if(!$(this).attr('id').includes(COLLAPSE_NO_SAVE_ID_INC) && !$(this).hasClass(COLLAPSE_NO_SAVE_CLASS)) {
                shownOnRefresh.push($(this).attr('id'));
            }
        }
        localStorage.setItem(collapse.LS_SHOWN_ON_REFRESH, JSON.stringify(shownOnRefresh));
    }
});

$('.collapse').on('hidden.bs.collapse', function() {
    // Si pas d'id do nothing
    if($(this).attr('id') !== undefined) {
        let shownOnRefresh = JSON.parse(localStorage.getItem(collapse.LS_SHOWN_ON_REFRESH));
        shownOnRefresh.splice( $.inArray($(this).attr('id'), shownOnRefresh), 1 );//remove item from array
        localStorage.setItem(collapse.LS_SHOWN_ON_REFRESH, JSON.stringify(shownOnRefresh));
    }
});
