import { Application } from "stimulus";
import { CheckAllController } from "../controllers/check_all_controller";

const application = Application.start();
application.register('checker', CheckAllController);

console.log('Stimulus loaded !');
