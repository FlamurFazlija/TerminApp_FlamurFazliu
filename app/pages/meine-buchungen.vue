<script setup>
const supabase = useSupabase()

const buchungen = ref([])
const meldung = ref('')
const fehler = ref('')

async function buchungenLaden() {
  meldung.value = ''
  fehler.value = ''

  const { data: userData } = await supabase.auth.getUser()

  if (!userData.user) {
    fehler.value = 'Bitte zuerst einloggen.'
    return
  }

  const { data, error } = await supabase
    .from('bookings')
    .select('id, name, matrikelnummer, anliegen, created_at, slots(start_time, end_time)')
    .order('created_at', { ascending: false })

  if (error) {
    fehler.value = error.message
  } else {
    buchungen.value = data
  }
}

async function stornieren(id) {
  const { error } = await supabase
    .from('bookings')
    .delete()
    .eq('id', id)

  if (error) {
    fehler.value = error.message
  } else {
    meldung.value = 'Buchung wurde storniert.'
    await buchungenLaden()
  }
}

function datumFormatieren(wert) {
  return new Date(wert).toLocaleString('de-DE')
}

onMounted(() => {
  buchungenLaden()
})
</script>

<template>
  <section>
    <h1>Meine Buchungen</h1>

    <p v-if="meldung" style="color: green;">
      {{ meldung }}
    </p>

    <p v-if="fehler" style="color: red;">
      {{ fehler }}
    </p>

    <p v-if="buchungen.length === 0 && !fehler">
      Keine Buchungen vorhanden.
    </p>

    <div v-for="buchung in buchungen" :key="buchung.id" class="buchung">
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
        <strong>Start:</strong> {{ datumFormatieren(buchung.slots.start_time) }}
      </p>

      <p>
        <strong>Ende:</strong> {{ datumFormatieren(buchung.slots.end_time) }}
      </p>

      <button @click="stornieren(buchung.id)">
        Buchung stornieren
      </button>
    </div>
  </section>
</template>

<style scoped>
.buchung {
  border: 1px solid #ccc;
  padding: 12px;
  margin-bottom: 12px;
  border-radius: 6px;
}

button {
  padding: 8px 12px;
}
</style>