import TurbolinksAdapter from 'vue-turbolinks';
import Vue from "@vue";
import App from "../components/target_kinds_form.vue";

Vue.use(TurbolinksAdapter);

document.addEventListener('turbo:load', () => {
  new Vue({
    render: h => h(App)
  }).$mount('target_kinds')
})
