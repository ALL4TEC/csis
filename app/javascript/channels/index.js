// Channel files are named *_channel.js

const channels = require.context('.', true, /_channel\.js$/);
channels.keys().forEach(channels);
