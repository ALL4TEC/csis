import { Controller } from 'stimulus';
import StimulusReflex from 'stimulus_reflex';
import { addResourceSubscription } from './subscription_controller';

export default class extends Controller {
  connect() {
    StimulusReflex.register(this);
    let listId = this.element.dataset.reportId;
    this.channel = addResourceSubscription(this.application.consumer.subscriptions, 'ReportsChannel', listId)
  }

  disconnect() {
    this.channel.unsubscribe();
  }

  destroy(event) {
    event.preventDefault();
    const target = event.currentTarget;
    const ok = confirm(target.dataset.reflexConfirm);
    if(ok) this.stimulate('ReportExport#destroy', target);
  }
}
