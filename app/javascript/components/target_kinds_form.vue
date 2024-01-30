<template>
  <div id='target_kinds' class="form-group select optional target_kind form-group-valid">
    <label class="form-control-label select optional" for="target_kind">{{ i18n.target.kind }}</label>
    <div class="d-flex flex-row justify-content-between align-items-center">
      <div class="dropdown show-tick form-control mx-1 select optional">
        <select v-model='choice' class="form-select optional" name="target[kind]" id="target_kind">
          <option></option>
          <option v-for='(value, key) in objects' :value='key'>{{ key }}</option>
        </select>
      </div>
    </div>
    <div v-for='(value, key) in objects' v-if="choice == key" :class="'form-group ' + value + ' optional target_' + value">
      <input :class="'form-control string ' + value + ' optional'" :type='value' :name="'target[' + value + ']'" :id="'target_' + value" autocomplete="off">
      <label :class="'form-control-label ' + value + 'optional'" :for="'target_' + value">{{ value.toUpperCase() }}</label>
    </div>
  </div>
</template>
<script>
  export default {
    el: '#target_kinds',
    data: function() {
      let element = document.getElementById('target_kinds');
      let objects = []
      if (element != null) {
        objects = element.dataset.objects ? JSON.parse(element.dataset.objects) : []
      }
      let i18n = {
        target: {
          kind: element.dataset.i18nTargetKind
        }
      }
      return { objects: objects, choice: '', i18n: i18n }
    }
  }
</script>
