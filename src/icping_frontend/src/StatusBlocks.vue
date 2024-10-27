<script setup>
defineProps({
  uptime: {
    type: Array,
    required: true,
    default: [],
  },
});
</script>

<template>
  <div class="uptime-container">
    <div>Health:</div>
    <div
      v-for="(status, index) in uptime"
      :key="index"
      class="status-rectangle"
      :class="{ up: status, down: !status }"
    ></div>
  </div>
</template>

<style scoped>
.uptime-container {
  display: flex;
  gap: 4px;
  padding: 10px;
}

.status-rectangle {
  width: 20px;
  height: 20px;
  border-radius: 2px;
}

.up {
  background-color: #4caf50;
}

.down {
  background-color: #f44336;
}
</style>
