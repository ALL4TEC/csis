export const LS_SHOWN_ON_REFRESH = 'shownOnRefresh';

export function loadCollapse() {
    // On page refresh
    const shownOnRefresh = JSON.parse(localStorage.getItem(LS_SHOWN_ON_REFRESH));
    for (let i in shownOnRefresh ) {
        $('#' + shownOnRefresh [i]).collapse('show');
    }
    console.log('Collapse history loaded !')
}
    
export function getShownCollapseFromLS() {
    // Stockage Plier/déplier
    let shownOnRefresh = JSON.parse(localStorage.getItem(LS_SHOWN_ON_REFRESH));
    if (shownOnRefresh === null) {
        shownOnRefresh = [];
        localStorage.setItem(LS_SHOWN_ON_REFRESH, JSON.stringify(shownOnRefresh));
    }
}
