import { callModal, setModalTitleAndContent } from "./ajax_modal";

const JOB_DEBUG_BTN = '.job-debug-btn';

$('main').on('click', JOB_DEBUG_BTN, function() {
  // Get Job id value
  const job_id = this.parentElement.parentElement.dataset['jobIdValue'];
  getJobDetail(job_id);
});

function handleSuccess(data) {
  setModalTitleAndContent('JOB EXCEPTION', data.html);
}

function getJobDetail(job_id) {
  callModal(`/jobs/${job_id}`, 'GET', handleSuccess);
}
