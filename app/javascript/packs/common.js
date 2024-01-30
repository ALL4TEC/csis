export const HIDE_CLASS = 'hide';
export const SHOW_CLASS = 'show';
export const D_NONE_CLASS = 'd-none';
export const BLOCK = 'block';
export const ACTIVE_CLASS = 'active';

/**
 * Add 'd-none' class to element and remove `d-${value}` class
 * @param {*} selector: jquery html selector
 * @param {*} value: css class: flex, block, inline, inline... etc
 * @see bootstrap documentation for more informations
 */
export function dNoneElement(selector, value = BLOCK) {
  $(selector).addClass(D_NONE_CLASS);
  $(selector).removeClass(`d-${value}`);
}

/**
 * Remove 'd-none' class to element and add 'd-${value}'
 * @param {*} selector: jquery html selector
 * @param {*} value: @see https://getbootstrap.com/docs/4.0/utilities/display/#notation
 */
export function displayElement(selector, value = BLOCK) {
  $(selector).removeClass(D_NONE_CLASS);
  $(selector).addClass(`d-${value}`);
}

/** Add class hide and remove class show of element_selector */
export function hideElement(element_selector) {
    $(element_selector).removeClass(SHOW_CLASS);
    $(element_selector).addClass(HIDE_CLASS);
}

/** Add class show and remove class hide of element_selector */
export function showElement(element_selector) {
    $(element_selector).removeClass(HIDE_CLASS);
    $(element_selector).addClass(SHOW_CLASS);
}

/** Call hideElement to each element of elementsArray */
export function hideElements(elementsArray) {
    elementsArray.each( function() {
        hideElement($(this));
    });
}

/** Call showElement to each element of elementsArray */
export function showElements(elementsArray) {
    elementsArray.each( function() {
        showElement($(this));
    });
}

/** Add active class */
export function activateElement(element_selector) {
    element_selector.addClass(ACTIVE_CLASS);
}

/** Remove active class */
export function deactivateElement(element_selector) {
    element_selector.removeClass(ACTIVE_CLASS);
}

export function isActive(element_selector) {
    element_selector.hasClass(ACTIVE_CLASS);
}

/** Call deactivateElement on each element of elementsArray */
export function deactivateElements(elementsArray) {
    elementsArray.each( function() {
        deactivateElement($(this));
    });
}
