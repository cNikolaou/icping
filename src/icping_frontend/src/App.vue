<script setup>
import { ref, onMounted, watch, onBeforeUnmount } from 'vue';
import { icping_backend } from 'declarations/icping_backend/index';

import StatusBlocks from './StatusBlocks.vue';

const url = ref('');
const uptime = ref([]);
let intervalId;

onMounted(async () => {
  await icping_backend.getFrequency().then((response) => {
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
  <main>
    <img src="/logo2.svg" alt="DFINITY logo" />
    <h2>ICPing: On-chain healthchecker</h2>
    <br />

    <br />
    <form action="#" @submit="handleSubmit">
      <label for="url">Enter the url:</label>
      <input id="url" alt="Name" type="text" :value="url" />
      <button type="submit">Select endpoint</button>
    </form>
    <section>Endpoint: {{ url }}</section>
    <StatusBlocks :uptime="uptime" />
  </main>
</template>

<style scoped>
body {
  font-family: sans-serif;
  font-size: 1.5rem;
}

h2 {
  display: block;
  margin: auto;
}

img {
  max-width: 50vw;
  max-height: 25vw;
  display: block;
  margin: auto;
}

form {
  display: flex;
  justify-content: center;
  gap: 0.5em;
  flex-flow: row wrap;
  max-width: 40vw;
  margin: auto;
  align-items: baseline;
}

button[type='submit'] {
  padding: 5px 20px;
  margin: 10px auto;
  float: right;
}

#greeting {
  margin: 10px auto;
  padding: 10px 60px;
  border: 1px solid #222;
}

#greeting:empty {
  display: none;
}
</style>
