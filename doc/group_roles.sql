-- Group role management: run this in the Supabase SQL editor.
--
-- Rules enforced server-side (client UI checks alone can be bypassed):
--   * exactly one admin per group
--   * transfer_admin: caller (admin) atomically becomes 'member', target becomes 'admin'
--   * promote member -> sub_admin: admin or sub_admin may call
--   * demote sub_admin -> member: admin only
--   * kick: admin kicks anyone but self; sub_admin kicks plain members only
--
-- Mechanism: SECURITY DEFINER RPCs + revoking direct update/delete on
-- group_members, so the checks below are the only write path for roles/kicks.

revoke update, delete on public.group_members from anon, authenticated;

-- Atomic admin transfer: caller must be the admin; caller -> member, target -> admin.
create or replace function public.transfer_admin(p_group_id uuid, p_new_admin_id uuid)
returns void
language plpgsql security definer set search_path = public
as $$
declare
  v_caller uuid := auth.uid();
  v_caller_role text;
  v_target_role text;
begin
  select permission into v_caller_role
    from group_members where group_id = p_group_id and user_id = v_caller;
  select permission into v_target_role
    from group_members where group_id = p_group_id and user_id = p_new_admin_id;

  if v_caller_role is distinct from 'admin' then
    raise exception 'Only the admin can transfer admin.';
  end if;
  if v_target_role is null then
    raise exception 'Target is not a member of this group.';
  end if;
  if p_new_admin_id = v_caller then
    raise exception 'You are already the admin.';
  end if;

  update group_members set permission = 'member'
    where group_id = p_group_id and user_id = v_caller;
  update group_members set permission = 'admin'
    where group_id = p_group_id and user_id = p_new_admin_id;
end;
$$;

-- Promote member -> sub_admin (admin or sub_admin).
-- Demote sub_admin -> member (admin only). Nothing else is legal;
-- 'admin' is only reachable via transfer_admin.
create or replace function public.set_member_role(p_group_id uuid, p_target_id uuid, p_role text)
returns void
language plpgsql security definer set search_path = public
as $$
declare
  v_caller uuid := auth.uid();
  v_caller_role text;
  v_target_role text;
begin
  select permission into v_caller_role
    from group_members where group_id = p_group_id and user_id = v_caller;
  select permission into v_target_role
    from group_members where group_id = p_group_id and user_id = p_target_id;

  if p_target_id = v_caller then
    raise exception 'You cannot change your own role.';
  end if;

  if p_role = 'sub_admin' then
    if v_target_role is distinct from 'member'
       or v_caller_role not in ('admin', 'sub_admin') then
      raise exception 'Not allowed.';
    end if;
  elsif p_role = 'member' then
    if v_target_role is distinct from 'sub_admin'
       or v_caller_role is distinct from 'admin' then
      raise exception 'Only the admin can demote a sub-admin.';
    end if;
  else
    raise exception 'Invalid role.';
  end if;

  update group_members set permission = p_role
    where group_id = p_group_id and user_id = p_target_id;
end;
$$;

-- Kick: admin kicks anyone but self; sub_admin kicks plain members only.
create or replace function public.kick_member(p_group_id uuid, p_target_id uuid)
returns void
language plpgsql security definer set search_path = public
as $$
declare
  v_caller uuid := auth.uid();
  v_caller_role text;
  v_target_role text;
begin
  select permission into v_caller_role
    from group_members where group_id = p_group_id and user_id = v_caller;
  select permission into v_target_role
    from group_members where group_id = p_group_id and user_id = p_target_id;

  if v_target_role is null then
    raise exception 'Target is not a member of this group.';
  end if;
  if p_target_id = v_caller then
    raise exception 'You cannot kick yourself.';
  end if;
  if not ( v_caller_role = 'admin'
        or (v_caller_role = 'sub_admin' and v_target_role = 'member') ) then
    raise exception 'Not allowed.';
  end if;

  delete from group_members
    where group_id = p_group_id and user_id = p_target_id;
end;
$$;
