<template>
  <div id='statistic_exports'>
    <div class='col'>
      <div class='row w-100 d-flex align-items-start'>
        <div class='col'>
          <div class='card'>
            <div class='card-header'>
              <h5>{{ i18n.object }}</h5>
            </div>
            <div class='card-body p-2'>
              <div class="mt-0">
                <select class="form-select required" name="object" id="object" v-model='choice'>
                  <option></option>
                  <option v-for='(value, key) in objects' :value='key' :label='value.name'>{{ value.name }}</option>
                </select>
              </div>
            </div>
          </div>
        </div>
        <div class='col'>
          <div class='card'>
            <div class='card-header'>
              <h5>{{ i18n.columns }}</h5>
            </div>
            <div v-if="choice !== ''" class='card-body p-2'>
              <div class="form-group mt-0">
                <div class='form-check' v-for='(value, key) in objects[choice].columns'>
                  <input class='form-check-input check_boxes optional' type="checkbox" name='columns[]' :value='key' :label='value'>
                  <label for="checkbox">{{ value }}</label>
                </div>
              </div>
            </div>
          </div>
        </div>
        <div class='col'>
          <div class="form-group mt-0">
            <button type='submit' class='btn btn-primary' data-bs-toggle='tooltip' :title='i18n.export'>
              <i aria-hidden='true' class="material-icons align-middle">{{ icons.export }}</i>
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
<script>
  export default {
    el: '#statistic_exports',
    data: function() {
      let element = document.getElementById('statistic_exports');
      let objects = []
      if (element != null) {
        objects = element.dataset.objects ? JSON.parse(element.dataset.objects) : []
      }
      let icons = {
        export: element.dataset.iconsExport
      }
      let i18n = {
        object: element.dataset.i18nLabelsObject,
        columns: element.dataset.i18nLabelsColumns,
        export: element.dataset.i18nLabelsExport
      }
      return { objects: objects, choice: '', icons: icons, i18n: i18n }
    }
  }
</script>
