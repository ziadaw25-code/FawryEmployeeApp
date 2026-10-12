create extension if not exists pgcrypto;

create table if not exists public.profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 full_name text not null default '', role text not null default 'employee' check (role in ('employee','manager','admin')),
 employee_id uuid null, active boolean not null default true, created_at timestamptz not null default now()
);
create table if not exists public.employees (
 id uuid primary key default gen_random_uuid(), full_name text not null, employee_code text unique,
 hire_date date, email text, receipt_limit numeric, pos_limit numeric, work_location text, notes text,
 active boolean not null default true, created_at timestamptz not null default now()
);
alter table public.profiles drop constraint if exists profiles_employee_fk;
alter table public.profiles add constraint profiles_employee_fk foreign key (employee_id) references public.employees(id) on delete set null;
create table if not exists public.attendance (
 id uuid primary key default gen_random_uuid(), employee_id uuid not null references public.employees(id) on delete cascade,
 work_date date not null, check_in timestamptz, check_out timestamptz, check_in_lat double precision, check_in_lng double precision,
 check_out_lat double precision, check_out_lng double precision, cards integer default 0, fawry_yawmy integer default 0,
 created_at timestamptz not null default now(), unique(employee_id, work_date)
);
create table if not exists public.location_samples (
 id uuid primary key default gen_random_uuid(), employee_id uuid not null references public.employees(id) on delete cascade,
 attendance_id uuid references public.attendance(id) on delete cascade, captured_at timestamptz not null default now(),
 latitude double precision not null, longitude double precision not null, accuracy_m double precision
);
create table if not exists public.monthly_performance (
 id uuid primary key default gen_random_uuid(), employee_id uuid not null references public.employees(id) on delete cascade,
 year integer not null, month integer not null, cards integer not null default 0, fawry_yawmy integer not null default 0,
 unique(employee_id, year, month)
);
create table if not exists public.requests (
 id uuid primary key default gen_random_uuid(), employee_id uuid not null references public.employees(id) on delete cascade,
 type text not null, message text, status text not null default 'pending' check(status in ('pending','approved','rejected')),
 manager_note text, created_at timestamptz not null default now(), reviewed_at timestamptz
);
create table if not exists public.notifications (
 id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
 title text not null, body text not null, kind text not null default 'general', related_request_id uuid null references public.requests(id) on delete cascade,
 is_read boolean not null default false, created_at timestamptz not null default now()
);
create index if not exists idx_notifications_user_created on public.notifications(user_id, created_at desc);
create index if not exists idx_requests_employee_created on public.requests(employee_id, created_at desc);

alter table public.profiles enable row level security;
alter table public.employees enable row level security;
alter table public.attendance enable row level security;
alter table public.location_samples enable row level security;
alter table public.monthly_performance enable row level security;
alter table public.requests enable row level security;
alter table public.notifications enable row level security;

create or replace function public.is_manager() returns boolean language sql stable security definer set search_path=public as $$
 select exists(select 1 from public.profiles where id=auth.uid() and role in ('manager','admin') and active=true);
$$;
create or replace function public.my_employee_id() returns uuid language sql stable security definer set search_path=public as $$
 select employee_id from public.profiles where id=auth.uid() and active=true limit 1;
$$;
create or replace function public.user_id_for_employee(p_employee uuid) returns uuid language sql stable security definer set search_path=public as $$
 select id from public.profiles where employee_id=p_employee and active=true limit 1;
$$;

 drop policy if exists profiles_self_or_manager on public.profiles;
create policy profiles_self_or_manager on public.profiles for select using (id=auth.uid() or public.is_manager());
 drop policy if exists employees_self_or_manager on public.employees;
create policy employees_self_or_manager on public.employees for select using (public.is_manager() or id=public.my_employee_id());
 drop policy if exists employees_manager_write on public.employees;
create policy employees_manager_write on public.employees for all using (public.is_manager()) with check (public.is_manager());
 drop policy if exists attendance_self_or_manager on public.attendance;
create policy attendance_self_or_manager on public.attendance for select using (public.is_manager() or employee_id=public.my_employee_id());
 drop policy if exists attendance_self_insert on public.attendance;
create policy attendance_self_insert on public.attendance for insert with check (employee_id=public.my_employee_id() or public.is_manager());
 drop policy if exists attendance_self_update on public.attendance;
create policy attendance_self_update on public.attendance for update using (employee_id=public.my_employee_id() or public.is_manager()) with check (employee_id=public.my_employee_id() or public.is_manager());
 drop policy if exists location_self_or_manager on public.location_samples;
create policy location_self_or_manager on public.location_samples for select using (public.is_manager() or employee_id=public.my_employee_id());
 drop policy if exists location_self_insert on public.location_samples;
create policy location_self_insert on public.location_samples for insert with check (employee_id=public.my_employee_id() or public.is_manager());
 drop policy if exists performance_self_or_manager on public.monthly_performance;
create policy performance_self_or_manager on public.monthly_performance for select using (public.is_manager() or employee_id=public.my_employee_id());
 drop policy if exists performance_manager_write on public.monthly_performance;
create policy performance_manager_write on public.monthly_performance for all using (public.is_manager()) with check (public.is_manager());
 drop policy if exists requests_self_or_manager on public.requests;
create policy requests_self_or_manager on public.requests for select using (public.is_manager() or employee_id=public.my_employee_id());
 drop policy if exists requests_self_insert on public.requests;
create policy requests_self_insert on public.requests for insert with check (employee_id=public.my_employee_id());
 drop policy if exists requests_manager_update on public.requests;
create policy requests_manager_update on public.requests for update using (public.is_manager()) with check (public.is_manager());
 drop policy if exists notifications_self on public.notifications;
create policy notifications_self on public.notifications for select using (user_id=auth.uid());
 drop policy if exists notifications_self_update on public.notifications;
create policy notifications_self_update on public.notifications for update using (user_id=auth.uid()) with check (user_id=auth.uid());

create or replace function public.sync_monthly_performance() returns trigger language plpgsql security definer set search_path=public as $$
declare y integer; m integer; cid uuid; fid uuid; begin
  if NEW.check_out is null then return NEW; end if;
  y:=extract(year from NEW.work_date); m:=extract(month from NEW.work_date);
  insert into public.monthly_performance(employee_id,year,month,cards,fawry_yawmy) values(NEW.employee_id,y,m,coalesce(NEW.cards,0),coalesce(NEW.fawry_yawmy,0))
  on conflict(employee_id,year,month) do update set cards=(select coalesce(sum(a.cards),0) from public.attendance a where a.employee_id=NEW.employee_id and extract(year from a.work_date)=y and extract(month from a.work_date)=m and a.check_out is not null), fawry_yawmy=(select coalesce(sum(a.fawry_yawmy),0) from public.attendance a where a.employee_id=NEW.employee_id and extract(year from a.work_date)=y and extract(month from a.work_date)=m and a.check_out is not null);
  return NEW;
end; $$;
drop trigger if exists trg_sync_monthly on public.attendance;
create trigger trg_sync_monthly after insert or update of check_out,cards,fawry_yawmy on public.attendance for each row execute function public.sync_monthly_performance();

create or replace function public.notify_request_created() returns trigger language plpgsql security definer set search_path=public as $$
declare manager_id uuid; emp_name text; begin
 select full_name into emp_name from public.employees where id=NEW.employee_id;
 for manager_id in select id from public.profiles where role in ('manager','admin') and active=true loop
   insert into public.notifications(user_id,title,body,kind,related_request_id) values(manager_id,'طلب موظف جديد','تم إرسال طلب جديد من '||coalesce(emp_name,'موظف')||' ('||NEW.type||')','request',NEW.id);
 end loop; return NEW; end; $$;
drop trigger if exists trg_notify_request_created on public.requests;
create trigger trg_notify_request_created after insert on public.requests for each row execute function public.notify_request_created();

create or replace function public.notify_request_reviewed() returns trigger language plpgsql security definer set search_path=public as $$
declare uid uuid; msg text; begin
 if OLD.status=NEW.status then return NEW; end if;
 uid:=public.user_id_for_employee(NEW.employee_id); if uid is null then return NEW; end if;
 msg:=case when NEW.status='approved' then 'تمت الموافقة على طلبك.' when NEW.status='rejected' then 'تم رفض طلبك.' else 'تم تحديث طلبك.' end;
 if NEW.manager_note is not null and NEW.manager_note<>'' then msg:=msg||' ملاحظة المدير: '||NEW.manager_note; end if;
 insert into public.notifications(user_id,title,body,kind,related_request_id) values(uid,'تحديث طلبك',msg,'request_review',NEW.id); return NEW; end; $$;
drop trigger if exists trg_notify_request_reviewed on public.requests;
create trigger trg_notify_request_reviewed after update of status,manager_note on public.requests for each row execute function public.notify_request_reviewed();
