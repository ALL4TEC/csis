const DEBUG = process.env.NODE_ENV === "development"
const buildPath = DEBUG ? "vue/dist/vue.esm.js" : "vue/dist/vue.runtime.esm.js"
module.exports = {
  resolve: {
    alias: { "@vue": buildPath }
  }
}
