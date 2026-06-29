<script setup>
// Hinweis: Diese Datei wurde mit KI-Unterstuetzung erstellt und anschliessend angepasst und getestet.
const supabase = useSupabase()

const slots = ref([])
const buchungen = ref([])

const start = ref('')
const ende = ref('')

const meldung = ref('')
const fehler = ref('')

async function datenLaden() {
  const slotsAntwort = await supabase
    .from('slots')
    .select('*')
    .order('start_time')

  if (slotsAntwort.error) {
    fehler.value = slotsAntwort.error.message
  } else {
    slots.value = slotsAntwort.data
  }

  const buchungenAntwort = await supabase
    .from('bookings')
    .select('*, slots(start_time, end_time)')
    .order('created_at', { ascending: false })

  if (buchungenAntwort.error) {
    fehler.value = buchungenAntwort.error.message
  } else {
    buchungen.value = buchungenAntwort.data
  }
}

async function slotAnlegen() {
  fehler.value = ''
  meldung.value = ''

  const { error } = await supabase
    .from('slots')
    .insert({
      start_time: start.value,
      end_time: ende.value,
      is_blocked: false
    })

  if (error) {
    fehler.value = 'Slot konnte nicht angelegt werden.'
  } else {
    meldung.value = 'Slot wurde angelegt.'
    start.value = ''
    ende.value = ''
    datenLaden()
  }
}

async function slotSperren(slot) {
  const { error } = await supabase
    .from('slots')
    .update({
      is_blocked: !slot.is_blocked
    })
    .eq('id', slot.id)

  if (error) {
    fehler.value = 'Slot konnte nicht geÃ¤ndert werden.'
  } else {
    datenLaden()
  }
}

function datum(wert) {
  return new Date(wert).toLocaleString('de-DE')
}

onMounted(() => {
  datenLaden()
})
</script>

<template>
  <section>
    <h1>Admin</h1>

    <p v-if="meldung" style="color: green;">
      {{ meldung }}
    </p>

    <p v-if="fehler" style="color: red;">
      {{ fehler }}
    </p>

    <h2>Slot anlegen</h2>

    <label>
      Start
      <input v-model="start" type="datetime-local">
    </label>

    <label>
      Ende
      <input v-model="ende" type="datetime-local">
    </label>

    <button @click="slotAnlegen">
      Slot speichern
    </button>

    <h2>Slots verwalten</h2>

    <div v-for="slot in slots" :key="slot.id" class="box">
      <p>
        <strong>Start:</strong> {{ datum(slot.start_time) }}
      </p>

      <p>
        <strong>Ende:</strong> {{ datum(slot.end_time) }}
      </p>

      <p>
        <strong>Status:</strong>
        {{ slot.is_blocked ? 'gesperrt' : 'frei' }}
      </p>

      <button @click="slotSperren(slot)">
        {{ slot.is_blocked ? 'Freigeben' : 'Sperren' }}
      </button>
    </div>

    <h2>Alle Buchungen</h2>

    <div v-for="buchung in buchungen" :key="buchung.id" class="box">
      <p>
        <strong>Name:</strong> {{ buchung.name }}
      </p>

      <p>
        <strong>Matrikelnummer:</strong> {{ buchung.matrikelnummer }}
      </p>

      <p>
        <strong>Anliegen:</strong> {{ buchung.anliegen }}
      </p>

      <p>
        <strong>Termin:</strong> {{ datum(buchung.slots.start_time) }}
      </p>
    </div>
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
  padding: 8px 12px;
}

.box {
  border: 1px solid #ccc;
  padding: 12px;
  margin-top: 12px;
}
</style>
