<script setup>
import { ref, onMounted, watch, onBeforeUnmount } from 'vue';
import { icping_backend } from 'declarations/icping_backend/index';

import StatusBlocks from './StatusBlocks.vue';

const url = ref('');
const uptime = ref([]);
let intervalId;

onMounted(async () => {
  await icping_backend.getInterval().then((response) => {
    interval.value = parseInt(response);
  });

  await icping_backend.getUrl().then((response) => {
    url.value = response;
  });
});

watch(url, () => {
  if (url !== '') {
    intervalId = setInterval(async () => {
      uptime.value = await icping_backend.getUptime();
    }, interval.value * 1000);
  } else {
    stopUptimeReq();
  }
});

function stopUptimeReq() {
  if (intervalId !== undefined) {
    clearInterval(intervalID);
  }
}

onBeforeUnmount(() => {
  stopUptimeReq();
});

const interval = ref(1000);

async function handleSubmit(e) {
  e.preventDefault();
  const target = e.target;
  const urlValue = target.querySelector('#url').value;
  await icping_backend.setUrl(urlValue).then((response) => {
    url.value = response;
  });
  const host = url.value.split('//')[1].split('/')[0];
  await icping_backend.setHost(host).then();
}
</script>

<template>
  <main class="main-container">
    <img src="/logo2.svg" alt="DFINITY logo" />
    <h2>ICPing: On-chain healthchecker</h2>
    <br />

    <br />
    <form action="#" @submit="handleSubmit">
      <div>
        <label for="url">Enter the endpoint for the request:</label>
        <input id="url" alt="Name" type="text" :value="url" class="endpoint-input" />
      </div>
      <button type="submit">Select endpoint</button>
    </form>
    <hr />
    <div class="endpoint">Endpoint: {{ url }}</div>
    <StatusBlocks :uptime="uptime" />
  </main>
</template>

<style scoped>
body {
  font-family: sans-serif;
  font-size: 1.5rem;
}

img {
  max-width: 15vw;
  max-height: 15vw;
  display: block;
  margin: auto;
}

form {
  display: flex;
  justify-content: center;
  gap: 1rem;
  flex-flow: row wrap;

  align-items: baseline;
  padding-top: 10px;
  padding-bottom: 20px;
}

.endpoint {
  padding-top: 10px;
  padding-bottom: 10px;
}

button[type='submit'] {
  float: right;
}

.main-container {
  max-width: 600px;
  margin: 0 auto;
  padding: 2rem;
}

.endpoint-input {
  min-width: 500px;
  width: 100%;
}
</style>
