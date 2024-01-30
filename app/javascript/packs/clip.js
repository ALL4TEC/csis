import { showElement, hideElements } from "./common";

export const BTN_CLIP = '.btn-clip';

$('#main-container').on('click', BTN_CLIP, copyToClipboard);

const COPY_CLASS = '.copy';
const COPIED_CLASS = '.copied';
const ERROR_CLASS = '.error';

/** Show elementToShow and hide each element of elementsToHideArray */
function handleElementsVisibility(elementToShow, elementsToHideArray) {
  showElement(elementToShow);
  hideElements(elementsToHideArray);
}

function displayCopied(triggeringElement) {
  const elementToShow = triggeringElement.find(COPIED_CLASS);
  const elementsToHide = triggeringElement.find(COPY_CLASS).add(triggeringElement.find(ERROR_CLASS));
  handleElementsVisibility(elementToShow, elementsToHide);
}

function displayError(triggeringElement) {
  const elementToShow = triggeringElement.find(ERROR_CLASS);
  const elementsToHide = triggeringElement.find(COPY_CLASS).add(triggeringElement.find(COPIED_CLASS));
  handleElementsVisibility(elementToShow, elementsToHide);
}

function restoreDefault(element, originalTooltipTitle) {
  const elementToShow = element.find(COPY_CLASS);
  const elementsToHide = element.find(COPIED_CLASS).add(element.find(ERROR_CLASS));
  handleElementsVisibility(elementToShow, elementsToHide);
  setTooltipTitle(element, originalTooltipTitle);
}

function setTooltipTitle($this, title) {
  const tooltip = bootstrap.Tooltip.getInstance($this);
  tooltip.setContent({ '.tooltip-inner': title });
}

/** Copy targetted content of triggering element into clipboard */
export function copyToClipboard() {
    let $this = $(this);
    const originalTooltipTitle = $this.attr('data-bs-title');
    let copyTarget = $($this.attr('data-clipboard-target'));
    const contentToCopy = copyTarget.select().text();
    navigator.permissions.query( {name: "clipboard-write"} ).then(result => { 
        if (result.state == "granted" || result.state == "prompt") {
          /* write to the clipboard now */
          navigator.clipboard.writeText(contentToCopy).then(function() {
            /* clipboard successfully set */
            setTooltipTitle($this, 'copied!');
            displayCopied($this);
            setTimeout(function() {
              restoreDefault($this, originalTooltipTitle);
            }, 2000);
          }, function() {
            /* clipboard write failed */
            setTooltipTitle($this, 'error during copy!');
            displayError($this);
            setTimeout(function() {
              restoreDefault($this, originalTooltipTitle);
            }, 2000);
          });
        } else {
            alert('Navigator does not allow copy to clipboard feature');
        }
      });
}

console.log('clipboard loaded !');
