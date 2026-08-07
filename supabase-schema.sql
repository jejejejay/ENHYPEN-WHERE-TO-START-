-- ENHYPEN, WHERE TO START? shared FAN PICKS backend
-- Run this in Supabase SQL Editor once.

create extension if not exists pgcrypto;

create table if not exists public.fan_content (
  id uuid primary key default gen_random_uuid(),
  section text not null check (section in ('shorts','stage','variety')),
  platform text not null default 'Other',
  url text not null,
  title text not null check (char_length(title) between 1 and 100),
  point text not null check (char_length(point) between 1 and 80),
  timestamp_label text,
  nickname text not null default 'ANONYMOUS' check (char_length(nickname) <= 24),
  thumbnail_url text,
  approved boolean not null default true,
  created_at timestamptz not null default now()
);

alter table public.fan_content enable row level security;

drop policy if exists "fan content public read" on public.fan_content;
create policy "fan content public read"
on public.fan_content for select
using (approved = true);

drop policy if exists "fan content public insert" on public.fan_content;
create policy "fan content public insert"
on public.fan_content for insert
to anon, authenticated
with check (section in ('shorts','stage','variety') and approved = true);

create table if not exists public.content_reactions (
  content_id text primary key,
  fire integer not null default 0 check (fire >= 0),
  heart integer not null default 0 check (heart >= 0),
  eyes integer not null default 0 check (eyes >= 0),
  updated_at timestamptz not null default now()
);

alter table public.content_reactions enable row level security;

drop policy if exists "reactions public read" on public.content_reactions;
create policy "reactions public read"
on public.content_reactions for select
using (true);

create or replace function public.change_content_reaction(
  p_content_id text,
  p_kind text,
  p_delta integer
)
returns public.content_reactions
language plpgsql
security definer
set search_path = public
as $$
declare
  result public.content_reactions;
begin
  if p_kind not in ('fire','heart','eyes') then
    raise exception 'invalid reaction kind';
  end if;
  if p_delta not in (-1,1) then
    raise exception 'invalid reaction delta';
  end if;

  insert into public.content_reactions(content_id)
  values (p_content_id)
  on conflict (content_id) do nothing;

  if p_kind = 'fire' then
    update public.content_reactions
      set fire = greatest(0, fire + p_delta), updated_at = now()
      where content_id = p_content_id returning * into result;
  elsif p_kind = 'heart' then
    update public.content_reactions
      set heart = greatest(0, heart + p_delta), updated_at = now()
      where content_id = p_content_id returning * into result;
  else
    update public.content_reactions
      set eyes = greatest(0, eyes + p_delta), updated_at = now()
      where content_id = p_content_id returning * into result;
  end if;

  return result;
end;
$$;

grant execute on function public.change_content_reaction(text,text,integer) to anon, authenticated;

-- Optional public thumbnail bucket for fan-uploaded images.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'fan-thumbnails',
  'fan-thumbnails',
  true,
  1048576,
  array['image/jpeg','image/png','image/webp','image/gif']
)
on conflict (id) do update
set public = true,
    file_size_limit = 1048576,
    allowed_mime_types = array['image/jpeg','image/png','image/webp','image/gif'];

drop policy if exists "fan thumbnails public upload" on storage.objects;
create policy "fan thumbnails public upload"
on storage.objects for insert
to anon, authenticated
with check (bucket_id = 'fan-thumbnails');
