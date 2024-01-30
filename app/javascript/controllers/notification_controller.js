import { Controller } from 'stimulus';
import StimulusReflex from 'stimulus_reflex';

export default class extends Controller {
  connect() {
    StimulusReflex.register(this);
  }

  toggle_state(event) {
    event.preventDefault();
    this.stimulate('Notification#toggle_state', event.target);
  }

  clear(event) {
    event.preventDefault();
    this.stimulate('Notification#clear', event.target);
  }

  clear_all(event) {
    event.preventDefault();
    this.stimulate('Notification#clear_all', event.target);
  }

  restore_all(event) {
    event.preventDefault();
    this.stimulate('Notification#restore_all', event.target);
  }

  read_all(event) {
    event.preventDefault();
    this.stimulate('Notification#read_all', event.target);
  }

  unread_all(event) {
    event.preventDefault();
    this.stimulate('Notification#unread_all', event.target);
  }
}