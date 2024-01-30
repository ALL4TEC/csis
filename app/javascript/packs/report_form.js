// To reference this file, add <%= javascript_pack_tag 'report_form' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb
import { Application } from "stimulus";
import { FilterController } from '../controllers/filter_controller';

const application = Application.start();
application.register('filter', FilterController);

console.log('Stimulus loaded !')
