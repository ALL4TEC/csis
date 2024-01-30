import TurbolinksAdapter from 'vue-turbolinks'
import Vue from "@vue"
import App from "../components/pentest_contents.vue";

Vue.use(TurbolinksAdapter);

document.addEventListener('turbo:load', () => {
  new Vue({
    render: h => h(App)
  }).$mount('managing_contents')
})
