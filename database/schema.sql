create extension if not exists pgcrypto;

create table if not exists public.service_triage_requests (
  id uuid primary key default gen_random_uuid(),
  request_id text not null unique,
  customer_name text not null,
  message text not null,
  location text not null,
  preferred_contact text not null
    check (preferred_contact in ('phone', 'email', 'sms')),
  source text not null,
  category text not null
    check (category in (
      'plumbing',
      'electrical',
      'heating_hvac',
      'appliance',
      'structural',
      'general',
      'other'
    )),
  urgency text not null
    check (urgency in ('low', 'medium', 'high', 'emergency')),
  summary text not null,
  assigned_team text not null,
  confidence double precision not null
    check (confidence >= 0 and confidence <= 1),
  classification_reason text not null,
  priority text not null
    check (priority in ('P1', 'P2', 'P3', 'P4')),
  sla_minutes integer not null
    check (sla_minutes > 0),
  needs_human_review boolean not null,
  requires_immediate_dispatch boolean not null,
  workflow_status text not null
    check (workflow_status in (
      'pending_human_review',
      'emergency_dispatch',
      'auto_routed'
    )),
  decision_mode text not null
    check (decision_mode in (
      'human_assisted',
      'automated_with_escalation',
      'automated'
    )),
  received_at timestamptz not null,
  processed_at timestamptz not null,
  created_at timestamptz not null default now()
);

create index if not exists service_triage_requests_workflow_status_idx
  on public.service_triage_requests (workflow_status);

create index if not exists service_triage_requests_created_at_idx
  on public.service_triage_requests (created_at desc);

alter table public.service_triage_requests enable row level security;

comment on table public.service_triage_requests is
  'Synthetic AI service-request triage results for the portfolio workflow.';
