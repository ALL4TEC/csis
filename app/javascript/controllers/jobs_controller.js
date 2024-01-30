import { Controller } from 'stimulus';
import { addListSubscription } from './subscription_controller';

export default class extends Controller {
  static values = { id: String }

  connect() {
    this.channel = addListSubscription(this.application.consumer.subscriptions, 'JobsListChannel');
  }

  disconnect() {
    this.channel.unsubscribe();
  }
}