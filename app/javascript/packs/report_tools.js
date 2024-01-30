import TurbolinksAdapter from 'vue-turbolinks';
import Vue from "@vue";
import App from "../components/pentest_tools.vue";

Vue.use(TurbolinksAdapter);

document.addEventListener('turbo:load', () => {
  new Vue({
    render: h => h(App)
  }).$mount('managing_tools')
})
