-- =====================================================================
-- Innovo Motors Production Measurement Dashboard
-- Databaseschema voor Supabase (Postgres)
--
-- Plak dit hele script in Supabase -> SQL Editor -> New query -> Run.
-- Je kunt het script veilig opnieuw draaien; bestaande tabellen en
-- gegevens blijven daarbij ongemoeid.
-- =====================================================================

create extension if not exists pgcrypto;

-- ---------------------------------------------------------------- runs
create table if not exists public.runs (
  id            uuid primary key default gen_random_uuid(),
  code          text unique not null,
  name          text not null,
  date          date,
  week          int,
  target        int,
  available_min numeric,
  demand        int,
  variant       text,
  notes         text,
  stations      jsonb not null default '[]'::jsonb,
  queue         jsonb not null default '[]'::jsonb,
  order_week    int,
  strict_order  boolean not null default false,
  demo          boolean not null default false,
  started_at    timestamptz,
  ended_at      timestamptz,
  created_at    timestamptz not null default now()
);

-- -------------------------------------------------------------- events
-- Append-only: de bron van waarheid. De primary key is de UUID die de
-- telefoon zelf genereert, zodat opnieuw verzenden van hetzelfde event
-- nooit een dubbele regel oplevert.
create table if not exists public.events (
  id         uuid primary key,
  run_id     uuid not null references public.runs(id) on delete cascade,
  ts         timestamptz not null,
  type       text not null,
  motor_id   text,
  station_id text,
  actor      text,
  payload    jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);
create index if not exists events_run_created_idx on public.events (run_id, created_at);
create index if not exists events_run_ts_idx      on public.events (run_id, ts);

-- ------------------------------------------------- Row Level Security
alter table public.runs   enable row level security;
alter table public.events enable row level security;

-- Het run-id dat de app als header meestuurt. Dat id krijg je alleen
-- terug als je de runcode kent (zie join_run hieronder).
create or replace function public.req_run_id() returns uuid
language sql stable as $$
  select nullif(current_setting('request.headers', true)::json ->> 'x-run-id', '')::uuid
$$;

drop policy if exists runs_select on public.runs;
drop policy if exists runs_insert on public.runs;
drop policy if exists runs_update on public.runs;
drop policy if exists runs_delete on public.runs;

-- Lezen, bijwerken en verwijderen kan alleen voor de run waarvan je het
-- id kent. Zonder runcode kun je dus geen enkele run van een andere
-- groep zien, wijzigen of wissen.
create policy runs_select on public.runs for select to anon
  using (id = public.req_run_id());
create policy runs_insert on public.runs for insert to anon
  with check (true);
create policy runs_update on public.runs for update to anon
  using (id = public.req_run_id()) with check (id = public.req_run_id());
create policy runs_delete on public.runs for delete to anon
  using (id = public.req_run_id());

drop policy if exists events_select on public.events;
drop policy if exists events_insert on public.events;

create policy events_select on public.events for select to anon
  using (run_id = public.req_run_id());
create policy events_insert on public.events for insert to anon
  with check (run_id = public.req_run_id());
-- Bewust GEEN update- of delete-policy op events: metingen kunnen niet
-- worden gewijzigd of gewist. Een verkeerde klik wordt teruggedraaid met
-- een correctie-event ("undo"), niet door de geschiedenis aan te passen.

-- ----------------------------------------------------- meedoen met code
create or replace function public.join_run(p_code text)
returns setof public.runs
language sql security definer set search_path = public as $$
  select * from public.runs where upper(code) = upper(trim(p_code)) limit 1;
$$;

-- ------------------------------------------------------- servertijd
-- Wordt gebruikt om de klokafwijking van elke telefoon te bepalen.
create or replace function public.server_now() returns timestamptz
language sql stable as $$ select now() $$;

revoke all on function public.join_run(text)  from public, anon;
revoke all on function public.server_now()    from public, anon;
grant execute on function public.join_run(text) to anon;
grant execute on function public.server_now()   to anon;

-- --------------------------------------------- realtime (optioneel)
-- De app werkt zonder dit blok: de poll-lus haalt nieuwe events elke
-- twee seconden op. Broadcast maakt het alleen nog directer.
do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    begin
      alter publication supabase_realtime add table public.events;
    exception when duplicate_object then null;
    end;
  end if;
end $$;
