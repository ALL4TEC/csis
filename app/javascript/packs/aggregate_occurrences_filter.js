// To reference this file, add <%= javascript_pack_tag 'report_form' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb
import { Application } from "stimulus";
import { OccurrencesFilterController } from '../controllers/occurrences_filter_controller';

const application = Application.start();
application.register('filter', OccurrencesFilterController);

console.log('Stimulus loaded !');
