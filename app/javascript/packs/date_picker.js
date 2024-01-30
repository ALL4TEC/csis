import { Datepicker, DateRangePicker } from 'vanillajs-datepicker';
import fr from 'vanillajs-datepicker/js/i18n/locales/fr.js';
Object.assign(Datepicker.locales, fr);

$('.input-daterange').each(function(index, elem) {
  const rangePicker = new DateRangePicker(elem, {
    // ...options
    container: getElementContainer(elem),
    format: 'yyyy-mm-dd',
    startDate: '-18m',
    todayBtn: true,
    clearBtn: true,
    todayHighlight: true,
    buttonClass: 'btn',
    maxDate: new Date()
  });
});

$('.input-datepicker').each(function(index, elem) {
  const datePicker = new Datepicker(elem, {
    // ...options
    container: getElementContainer(elem),
    autohide: true,
    format: 'yyyy-mm-dd',
    todayBtn: true,
    clearBtn: true,
    todayHighlight: true,
    language: "<%= I18n.locale %>",
    buttonClass: 'btn',
    maxDate: new Date(),
    showOnFocus: false
  });
});

$('.input-future_datepicker').each(function(index, elem) {
  const datePicker = new Datepicker(elem, {
    // ...options
    container: getElementContainer(elem),
    autohide: true,
    format: 'yyyy-mm-dd',
    todayBtn: true,
    clearBtn: true,
    todayHighlight: true,
    language: "<%= I18n.locale %>",
    buttonClass: 'btn',
    showOnFocus: false
  });
});

function getElementContainer(element) {
  return element.dataset.container;
}

console.log('Date picker !');
