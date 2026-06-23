<script setup>
const supabase = useSupabase()

const email = ref('')
const passwort = ref('')
const meldung = ref('')
const fehler = ref('')

async function registrieren() {
  meldung.value = ''
  fehler.value = ''

  const { error } = await supabase.auth.signUp({
    email: email.value,
    password: passwort.value
  })

  if (error) {
    fehler.value = error.message
  } else {
    meldung.value = 'Account wurde erstellt.'
  }
}

async function einloggen() {
  meldung.value = ''
  fehler.value = ''

  const { error } = await supabase.auth.signInWithPassword({
    email: email.value,
    password: passwort.value
  })

  if (error) {
    fehler.value = error.message
  } else {
    meldung.value = 'Login erfolgreich.'
  }
}

async function ausloggen() {
  await supabase.auth.signOut()
  meldung.value = 'Du wurdest ausgeloggt.'
}
</script>

<template>
  <section>
    <h1>Login</h1>

    <label>
      E-Mail
      <input v-model="email" type="email">
    </label>

    <label>
      Passwort
      <input v-model="passwort" type="password">
    </label>

    <button @click="einloggen">Einloggen</button>
    <button @click="registrieren">Registrieren</button>
    <button @click="ausloggen">Ausloggen</button>

    <p v-if="meldung" style="color: green;">
      {{ meldung }}
    </p>

    <p v-if="fehler" style="color: red;">
      {{ fehler }}
    </p>
  </section>
</template>

<style scoped>
label {
  display: block;
  margin-bottom: 12px;
}

input {
  display: block;
  width: 100%;
  padding: 8px;
  margin-top: 4px;
}

button {
  margin-right: 8px;
  padding: 8px 12px;
}
</style>