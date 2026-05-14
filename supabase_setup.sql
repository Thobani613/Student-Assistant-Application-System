-- ============================================================
-- TPG316C Group Assignment – Supabase Database Setup Script
-- Run this in your Supabase SQL Editor
-- ============================================================

-- 1. PROFILES TABLE (extends auth.users)
create table if not exists public.profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  email       text not null,
  full_name   text not null,
  student_number text not null,
  role        text not null default 'student' check (role in ('student', 'admin')),
  created_at  timestamptz default now()
);

-- Auto-create a profile when a new user signs up
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, full_name, student_number, role)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'full_name', ''),
    coalesce(new.raw_user_meta_data->>'student_number', ''),
    coalesce(new.raw_user_meta_data->>'role', 'student')
  );
  return new;
end;
$$ language plpgsql security definer;

create or replace trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- 2. APPLICATIONS TABLE
create table if not exists public.applications (
  id                          uuid primary key default gen_random_uuid(),
  user_id                     uuid not null references auth.users(id) on delete cascade,
  student_name                text not null,
  student_number              text not null,
  year_of_study               int not null check (year_of_study between 1 and 3),
  module1_level               text not null,
  module1_name                text not null,
  module2_level               text,
  module2_name                text,
  meets_minimum_requirements  boolean not null default false,
  document_url                text,
  status                      text not null default 'pending'
                                check (status in ('pending', 'approved', 'rejected')),
  created_at                  timestamptz default now(),
  updated_at                  timestamptz default now()
);

-- 3. ROW LEVEL SECURITY (RLS)

-- Profiles
alter table public.profiles enable row level security;

create policy "Users can view own profile"
  on public.profiles for select
  using (auth.uid() = id);

create policy "Admins can view all profiles"
  on public.profiles for select
  using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

-- Applications
alter table public.applications enable row level security;

create policy "Students can view own applications"
  on public.applications for select
  using (auth.uid() = user_id);

create policy "Students can insert own application"
  on public.applications for insert
  with check (auth.uid() = user_id);

create policy "Students can update pending own application"
  on public.applications for update
  using (auth.uid() = user_id and status = 'pending');

create policy "Students can delete pending own application"
  on public.applications for delete
  using (auth.uid() = user_id and status = 'pending');

create policy "Admins can view all applications"
  on public.applications for select
  using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

create policy "Admins can update any application"
  on public.applications for update
  using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

create policy "Admins can delete any application"
  on public.applications for delete
  using (
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

-- 4. STORAGE BUCKET for supporting documents
insert into storage.buckets (id, name, public)
values ('supporting-documents', 'supporting-documents', false)
on conflict do nothing;

create policy "Users can upload own documents"
  on storage.objects for insert
  with check (bucket_id = 'supporting-documents' and auth.uid()::text = (storage.foldername(name))[1]);

create policy "Users can view own documents"
  on storage.objects for select
  using (bucket_id = 'supporting-documents' and auth.uid()::text = (storage.foldername(name))[1]);

create policy "Admins can view all documents"
  on storage.objects for select
  using (
    bucket_id = 'supporting-documents' and
    exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'admin'
    )
  );

-- ============================================================
-- SAMPLE DATA (optional – for testing)
-- ============================================================
-- After creating users via Supabase Auth dashboard, update their roles:
-- UPDATE public.profiles SET role = 'admin' WHERE email = 'admin@university.ac.za';