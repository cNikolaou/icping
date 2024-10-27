<script setup>
import { ref, onMounted, watch, onBeforeUnmount } from 'vue';
import { icping_backend } from 'declarations/icping_backend/index';

const url = ref('');
let intervalId;

onMounted(async () => {
  await icping_backend.getFrequency().then((response) => {
    interval.value = parseInt(response);
    console.log('FETCH', interval.value);
  });
});

watch(url, () => {
  if (url !== '') {
    intervalId = setInterval(async () => {
      console.log('FETCH');
      const uptime = await icping_backend.getUptime();
      console.log(uptime);
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
  console.log(e);
  e.preventDefault();
  const target = e.target;
  const urlValue = target.querySelector('#url').value;
  console.log('URL:', urlValue);
  await icping_backend.setUrl(urlValue).then((response) => {
    console.log(response);
    url.value = response;
  });
  const host = url.value.split('//')[1].split('/')[0];
  await icping_backend.setHost(host).then();
}
</script>

<template>
  <main>
    <img src="/logo2.svg" alt="DFINITY logo" />
    <br />

    <br />
    <form action="#" @submit="handleSubmit">
      <label for="url">Enter the url:</label>
      <input id="url" alt="Name" type="text" />
      <button type="submit">Select endpoint</button>
    </form>
    <section>url: {{ url }}</section>
  </main>
</template>
