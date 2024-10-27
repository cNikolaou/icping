<script setup>
import { ref } from 'vue';
import { icping_backend } from 'declarations/icping_backend/index';

const url = ref('');
const tp = ref('');

async function getTimestamp() {
  await icping_backend.ping().then((response) => {
    tp.value = response;
  });
}

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
      <button type="submit">Click Me!</button>
    </form>
    <section>url: {{ url }}</section>
    <div>Timestamp: {{ tp }}</div>
    <button @click="getTimestamp">Ping</button>
  </main>
</template>
