-- Hinweis zur KI-Nutzung:
-- KI wurde bei einem kleinen Teil dieses Schemas als Hilfestellung genutzt.
-- Vor allem ging es um das Verstaendnis von Supabase, RLS und Fehlermeldungen.
-- Die SQL-Befehle wurden danach im Projekt getestet und angepasst.

-- Hinweis zur KI-Nutzung:
-- Bei Teilen dieses Datenbankschemas wurde KI als Hilfestellung genutzt,
-- vor allem zum besseren Verständnis von Supabase, RLS und typischen Fehlermeldungen.
-- Die SQL-Befehle wurden anschließend im Projekt getestet und angepasst.
-- Datenbankschema fÃ¼r die TerminApp

-- Nutzerprofile mit Rolle
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  role text not null default 'student'
);

-- Sprechstunden-Slots
create table slots (
  id uuid primary key default gen_random_uuid(),
  start_time timestamp not null,
  end_time timestamp not null,
  is_blocked boolean default false
);

-- Buchungen
create table bookings (
  id uuid primary key default gen_random_uuid(),
  slot_id uuid not null references slots(id) on delete cascade,
  user_id uuid not null default auth.uid() references profiles(id) on delete cascade,
  name text not null,
  matrikelnummer text not null,
  anliegen text not null,
  created_at timestamp default now(),

  -- verhindert Doppelbuchungen
  unique(slot_id)
);

-- Automatisch Profil erstellen, wenn ein Nutzer registriert wird
create or replace function handle_new_user()
returns trigger
language plpgsql
security definer
as $$
begin
  insert into profiles (id, email, role)
  values (new.id, new.email, 'student');

  return new;
end;
$$;

create trigger on_auth_user_created
after insert on auth.users
for each row
execute procedure handle_new_user();

-- PrÃ¼fen, ob aktueller Nutzer Admin ist
create or replace function is_admin()
returns boolean
language sql
security definer
as $$
  select exists (
    select 1
    from profiles
    where id = auth.uid()
    and role = 'admin'
  );
$$;

-- RLS aktivieren
alter table profiles enable row level security;
alter table slots enable row level security;
alter table bookings enable row level security;

-- Profile:
-- Nutzer sehen ihr eigenes Profil, Admins alle Profile
create policy profiles_select
on profiles
for select
using (
  id = auth.uid()
  or is_admin()
);

-- Slots:
-- Alle dÃ¼rfen Slots sehen
create policy slots_select
on slots
for select
using (true);

-- Nur Admins dÃ¼rfen Slots anlegen
create policy slots_insert
on slots
for insert
with check (is_admin());

-- Nur Admins dÃ¼rfen Slots Ã¤ndern
create policy slots_update
on slots
for update
using (is_admin())
with check (is_admin());

-- Buchungen:
-- Nutzer sehen nur eigene Buchungen, Admins alle
create policy bookings_select
on bookings
for select
using (
  user_id = auth.uid()
  or is_admin()
);

-- Nutzer dÃ¼rfen eigene Buchungen erstellen
create policy bookings_insert
on bookings
for insert
with check (
  user_id = auth.uid()
);

-- Nutzer dÃ¼rfen eigene Buchungen lÃ¶schen, Admins alle
create policy bookings_delete
on bookings
for delete
using (
  user_id = auth.uid()
  or is_admin()
);

-- Freie Slots anzeigen
create or replace function get_available_slots()
returns setof slots
language sql
security definer
as $$
  select *
  from slots
  where is_blocked = false
  and id not in (
    select slot_id
    from bookings
  )
  order by start_time;
$$;

grant execute on function get_available_slots() to anon;
grant execute on function get_available_slots() to authenticated;

