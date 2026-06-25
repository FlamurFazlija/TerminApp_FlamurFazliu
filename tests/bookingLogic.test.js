import { describe, it, expect } from 'vitest'
import {
  formularGueltig,
  istSlotGebucht,
  darfStornieren,
  freieSlots
} from '../utils/bookingLogic.js'

describe('Buchungslogik', function () {
  it('Formular ist gültig, wenn alle Felder ausgefüllt sind', function () {
    expect(formularGueltig('Max', '123456', 'Frage zur Klausur')).toBe(true)
  })

  it('Formular ist ungültig, wenn ein Feld leer ist', function () {
    expect(formularGueltig('', '123456', 'Frage')).toBe(false)
  })

  it('erkennt, ob ein Slot bereits gebucht ist', function () {
    const buchungen = [
      { slot_id: 'slot1' }
    ]

    expect(istSlotGebucht('slot1', buchungen)).toBe(true)
  })

  it('erlaubt Stornierung nur bei eigener Buchung', function () {
    const buchung = {
      user_id: 'user1'
    }

    expect(darfStornieren('user1', buchung)).toBe(true)
    expect(darfStornieren('user2', buchung)).toBe(false)
  })

  it('zeigt nur freie und nicht gesperrte Slots an', function () {
    const slots = [
      { id: 'slot1', is_blocked: false },
      { id: 'slot2', is_blocked: true },
      { id: 'slot3', is_blocked: false }
    ]

    const buchungen = [
      { slot_id: 'slot3' }
    ]

    expect(freieSlots(slots, buchungen)).toEqual([
      { id: 'slot1', is_blocked: false }
    ])
  })
})
