-- Group avatar storage: run in the Supabase SQL editor AFTER creating a
-- PUBLIC storage bucket named `group_img` (Dashboard -> Storage -> New bucket).
--
-- Server-side enforcement: only a group's admin or sub-admin may upload the
-- group avatar (object path is `<group_id>/avatar.png`) or update the
-- groups.group_avatar_url column. Client UI hides the button for members,
-- but these policies make the rule real.

-- Storage: admin/sub-admin of the group named by the top-level folder
-- may insert/update objects in group_img.
create policy "group avatar upload by admins"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'group_img'
  and exists (
    select 1 from public.group_members
    where group_id::text = (storage.foldername(name))[1]
      and user_id = auth.uid()
      and permission in ('admin', 'sub_admin')
  )
);

create policy "group avatar overwrite by admins"
on storage.objects for update to authenticated
using (
  bucket_id = 'group_img'
  and exists (
    select 1 from public.group_members
    where group_id::text = (storage.foldername(name))[1]
      and user_id = auth.uid()
      and permission in ('admin', 'sub_admin')
  )
);

-- Table: only admin/sub-admin may update a group row (covers group_avatar_url).
-- NOTE: if RLS is not yet enabled on public.groups, enabling it makes these
-- policies the only access path — the existing select/insert usage needs
-- matching policies too, hence the read/insert policies below.
alter table public.groups enable row level security;

create policy "groups readable by authenticated"
on public.groups for select to authenticated
using (true);

create policy "groups insert by creator"
on public.groups for insert to authenticated
with check (created_by = auth.uid());

create policy "groups update by group admins"
on public.groups for update to authenticated
using (
  exists (
    select 1 from public.group_members
    where group_id = groups.id
      and user_id = auth.uid()
      and permission in ('admin', 'sub_admin')
  )
);
