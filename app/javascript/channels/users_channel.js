// Client-side which assumes you've already requested
// the right to send web notifications.
import CableReady from 'cable_ready';
import consumer from "./consumer";

consumer.subscriptions.create('UsersChannel', {
  connected() {
    console.log('UsersChannel:Connected');
  },
  disconnected() {
    console.log('UsersChannel:Disconnected');
  },
  received(data) {
    console.log('UsersChannel:New data received');
    console.log(data);
    if (data.cableReady) CableReady.perform(data.operations)
  }
})