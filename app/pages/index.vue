<script setup>
const supabase = useSupabase()

const slots = ref([])
const name = ref('')
const matrikelnummer = ref('')
const anliegen = ref('')
const meldung = ref('')
const fehler = ref('')

async function slotsLaden() {
  const { data, error } = await supabase.rpc('get_available_slots')

  if (error) {
    fehler.value = error.message
  } else {
    slots.value = data
  }
}

async function buchen(slotId) {
  meldung.value = ''
  fehler.value = ''

  const { data } = await supabase.auth.getUser()

  if (!data.user) {
    fehler.value = 'Bitte zuerst einloggen.'
    return
  }

  if (!name.value || !matrikelnummer.value || !anliegen.value) {
    fehler.value = 'Bitte alle Felder ausfüllen.'
    return
  }

  const { error } = await supabase
    .from('bookings')
    .insert({
      slot_id: slotId,
      name: name.value,
      matrikelnummer: matrikelnummer.value,
      anliegen: anliegen.value
    })

  if (error) {
    fehler.value = 'Buchung nicht möglich. Der Slot ist vielleicht schon vergeben.'
  } else {
    meldung.value = 'Buchung erfolgreich.'
    name.value = ''
    matrikelnummer.value = ''
    anliegen.value = ''
    await slotsLaden()
  }
}

function datumFormatieren(wert) {
  return new Date(wert).toLocaleString('de-DE')
}

onMounted(() => {
  slotsLaden()
})
</script>

<template>
  <section>
    <h1>Verfügbare Sprechstunden-Slots</h1>

    <p v-if="meldung" style="color: green;">
      {{ meldung }}
    </p>

    <p v-if="fehler" style="color: red;">
      {{ fehler }}
    </p>

    <div class="formular">
      <h2>Buchungsdaten</h2>

      <label>
        Name
        <input v-model="name" type="text">
      </label>

      <label>
        Matrikelnummer
        <input v-model="matrikelnummer" type="text">
      </label>

      <label>
        Anliegen
        <textarea v-model="anliegen"></textarea>
      </label>
    </div>

    <p v-if="slots.length === 0">
      Keine freien Slots vorhanden.
    </p>

    <div v-for="slot in slots" :key="slot.id" class="slot">
      <p>
        <strong>Start:</strong> {{ datumFormatieren(slot.start_time) }}
      </p>
      <p>
        <strong>Ende:</strong> {{ datumFormatieren(slot.end_time) }}
      </p>

      <button @click="buchen(slot.id)">
        Diesen Slot buchen
      </button>
    </div>
  </section>
</template>

<style scoped>
.formular {
  border: 1px solid #ddd;
  padding: 16px;
  margin-bottom: 24px;
  border-radius: 6px;
}

label {
  display: block;
  margin-bottom: 12px;
}

input,
textarea {
  display: block;
  width: 100%;
  padding: 8px;
  margin-top: 4px;
}

.slot {
  border: 1px solid #ccc;
  padding: 12px;
  margin-bottom: 12px;
  border-radius: 6px;
}

button {
  padding: 8px 12px;
}
</style>