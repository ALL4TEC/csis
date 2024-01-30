import CableReady from 'cable_ready';

export function addListSubscription(subscriptions, channel) {
  addResourceSubscription(subscriptions, channel, '')
}

export function addResourceSubscription(subscriptions, channel, id) {
  return subscriptions.create({
    channel: channel,
    id: id
  },
  {
    connected() {
      console.log(`${channel}:${id}:Connected`);
    },
    disconnected() {
      console.log(`${channel}:${id}:Disconnected`);
    },
    received (data) {
      console.log(`${channel}:${id}:Received new data`);
      console.log(data);
      if (data.cableReady) CableReady.perform(data.operations)
    }
  });
}

export function removeChannelSubscription(channels, id) {
  let channel = channels.find(element => element.id == id);
  channel.unsubscribe();
  channels.splice(channels.indexOf(channel), 1);
}
