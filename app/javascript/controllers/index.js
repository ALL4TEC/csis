// append to the bottom of existing file contents
import consumer from '../channels/consumer';
import { Application } from 'stimulus';
import { definitionsFromContext } from 'stimulus/webpack-helpers';
import StimulusReflex from 'stimulus_reflex';

const application = Application.start();
const context = require.context(".", true, /\.js$/);
application.load(definitionsFromContext(context));
application.consumer = consumer;
StimulusReflex.initialize(application, { consumer });
// StimulusReflex.initialize(application, { consumer, controller, isolate: true })
StimulusReflex.debug = process.env.RAILS_ENV === 'development';
