import 'autosize/dist/autosize';

export const FORM_INPUT = '.form-control:not(.select):not(.bootstrap-select):not(.selectpicker):not(.datepicker)';

// On ajoute la classe .active aux elements .form-control ayant du contenu, autofocus ou un placeholder
export function handleFormControl() {
    let $this = $(this);
    let element = $this[0];
    if ( element.multiple == true ||
        element.value.length > 0 ||
        element.autofocus ||
        $this.attr('placeholder') !== undefined ) {
        $this.siblings('label').addClass('active');
    } else if ($this.validity) {
        $this.siblings('label').toggleClass('active', element.validity.badInput === true);
    } else {
        $this.siblings('label').removeClass('active');
    }
}

window.addEventListener(
  'resize',
  (e) => {
    if (document.activeElement && document.activeElement.matches('textarea')) {
      console.log('propagation stopped');
      e.stopPropagation();
    } else {
      console.log('propagation not stopped');
    }
  },
  true // enable useCapture here with this third argument
       // to stop propagation as early as possible
);

// Lors du focusout
$(FORM_INPUT).on("focusout", handleFormControl);
window.autosize = window.autosize ? window.autosize : require('autosize');
autosize($('textarea'));
