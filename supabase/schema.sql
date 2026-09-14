create extension if not exists "pgcrypto";

create table if not exists public.gym_settings (
 id uuid primary key default gen_random_uuid(),
 name text not null default 'POWER LIFT FITNESS',
 about text,
 phone text,
 alt_phone text,
 whatsapp text,
 instagram_url text,
 maps_url text,
 address text,
 timings text,
 hero_heading text default 'BUILD THE STRONGER VERSION.',
 hero_subtitle text default 'Train hard. Live strong.',
 hero_image_url text,
 logo_url text,
 facilities jsonb not null default '["Strength","Cardio","CrossFit","Yoga","Aerobics","Zumba","Steam"]'::jsonb,
 updated_at timestamptz default now()
);

create table if not exists public.membership_plans (
 id uuid primary key default gen_random_uuid(),
 name text not null,
 price numeric not null,
 description text,
 is_active boolean not null default true,
 is_featured boolean not null default false,
 sort_order integer not null default 0,
 created_at timestamptz default now(),
 updated_at timestamptz default now()
);

create table if not exists public.gallery (
 id uuid primary key default gen_random_uuid(),
 title text,
 caption text,
 media_type text not null default 'image' check(media_type in ('image','video')),
 storage_path text,
 public_url text,
 is_published boolean not null default true,
 created_at timestamptz default now()
);

create table if not exists public.enquiries (
 id uuid primary key default gen_random_uuid(),
 name text not null,
 phone text not null,
 date date,
 time time,
 type text,
 message text,
 status text not null default 'New' check(status in ('New','Contacted','Completed')),
 created_at timestamptz default now()
);

alter table public.gym_settings enable row level security;
alter table public.membership_plans enable row level security;
alter table public.gallery enable row level security;
alter table public.enquiries enable row level security;

create policy "public can read gym settings" on public.gym_settings for select using (true);
create policy "public can read active plans" on public.membership_plans for select using (is_active = true);
create policy "public can read published gallery" on public.gallery for select using (is_published = true);
create policy "public can submit enquiries" on public.enquiries for insert with check (true);

create policy "authenticated admins manage gym settings" on public.gym_settings for all to authenticated using (true) with check (true);
create policy "authenticated admins manage plans" on public.membership_plans for all to authenticated using (true) with check (true);
create policy "authenticated admins manage gallery" on public.gallery for all to authenticated using (true) with check (true);
create policy "authenticated admins manage enquiries" on public.enquiries for all to authenticated using (true) with check (true);

insert into public.gym_settings(name,about,phone,whatsapp,instagram_url,maps_url,address,timings)
select 'POWER LIFT FITNESS','Train with purpose. Build strength, discipline and confidence in a premium fitness environment.','+91 96606 19130','919660619130','https://www.instagram.com/powerliftfitnessgym?stkn=ZDgyMGxhZHk0Y3ow','https://maps.app.goo.gl/LSRNVPmsVhtAbqU37','5, Gulab Nagar C, Near RTO Office, Paota, Jodhpur, Rajasthan','Set by owner'
where not exists (select 1 from public.gym_settings);

insert into public.membership_plans(name,price,sort_order)
select * from (values ('1 Month',2500,1),('3 Months',6000,2),('6 Months',9000,3),('Yearly',15000,4),('Per Day',300,5),('Steam Bath',250,6)) as v(name,price,sort_order)
where not exists (select 1 from public.membership_plans);

insert into storage.buckets(id,name,public) values
('branding','branding',true),('gallery','gallery',true)
on conflict (id) do nothing;

create policy "public read branding" on storage.objects for select using (bucket_id='branding');
create policy "public read gallery" on storage.objects for select using (bucket_id='gallery');
create policy "authenticated upload branding" on storage.objects for insert to authenticated with check (bucket_id='branding');
create policy "authenticated update branding" on storage.objects for update to authenticated using (bucket_id='branding') with check (bucket_id='branding');
create policy "authenticated delete branding" on storage.objects for delete to authenticated using (bucket_id='branding');
create policy "authenticated upload gallery" on storage.objects for insert to authenticated with check (bucket_id='gallery');
create policy "authenticated update gallery" on storage.objects for update to authenticated using (bucket_id='gallery') with check (bucket_id='gallery');
create policy "authenticated delete gallery" on storage.objects for delete to authenticated using (bucket_id='gallery');

-- Confirmed membership terms supplied for POWER LIFT FITNESS.
create table if not exists public.gym_terms (
 id uuid primary key default gen_random_uuid(),
 term text not null,
 sort_order int not null default 0,
 created_at timestamptz not null default now()
);
alter table public.gym_terms enable row level security;
drop policy if exists "Public can read terms" on public.gym_terms;
create policy "Public can read terms" on public.gym_terms for select using (true);
drop policy if exists "Authenticated manage terms" on public.gym_terms;
create policy "Authenticated manage terms" on public.gym_terms for all to authenticated using (true) with check (true);

insert into public.gym_terms(term,sort_order)
select v.term,v.sort_order from (values
 ('Fees once paid are non-refundable, non-transferable and non-extendable.',1),
 ('Outside shoes are not allowed.',2),
 ('Membership transfer fee is ₹3,000.',3),
 ('Freeze facility is available for the 12-month package for one month only.',4)
) v(term,sort_order)
where not exists (select 1 from public.gym_terms);
