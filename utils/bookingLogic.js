export function formularGueltig(name, matrikelnummer, anliegen) {
  return name.length > 0 &&
    matrikelnummer.length > 0 &&
    anliegen.length > 0
}

export function istSlotGebucht(slotId, buchungen) {
  return buchungen.some(function (buchung) {
    return buchung.slot_id === slotId
  })
}

export function darfStornieren(userId, buchung) {
  return buchung.user_id === userId
}

export function freieSlots(slots, buchungen) {
  return slots.filter(function (slot) {
    const gebucht = istSlotGebucht(slot.id, buchungen)
    return slot.is_blocked === false && gebucht === false
  })
}
