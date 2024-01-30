SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.accounts (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    encrypted_login character varying,
    encrypted_password character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    name character varying NOT NULL,
    encrypted_login_iv character varying,
    encrypted_password_iv character varying,
    type character varying DEFAULT 'QualysConfig'::character varying NOT NULL,
    encrypted_api_key character varying,
    encrypted_api_key_iv character varying,
    url character varying,
    discarded_at timestamp without time zone,
    creator_id uuid,
    encrypted_secret_key character varying,
    encrypted_secret_key_iv character varying,
    external_application_id uuid,
    verify_ssl_certificate boolean DEFAULT true NOT NULL
);


--
-- Name: accounts_suppliers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.accounts_suppliers (
    account_id uuid,
    supplier_id uuid,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: accounts_teams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.accounts_teams (
    account_id uuid NOT NULL,
    team_id uuid NOT NULL,
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL
);


--
-- Name: accounts_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.accounts_users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    account_id uuid NOT NULL,
    user_id uuid NOT NULL,
    channel_id character varying,
    notify_on text[] DEFAULT '{action_state_update,comment_creation,export_generation,scan_launch_done,scan_created,scan_destroyed,exceeding_severity_threshold}'::text[]
);


--
-- Name: action_text_rich_texts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.action_text_rich_texts (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    body text,
    record_type character varying NOT NULL,
    record_id uuid NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: actions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.actions (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    state integer DEFAULT 0 NOT NULL,
    meta_state integer DEFAULT 0 NOT NULL,
    name text NOT NULL,
    description text,
    receiver_id uuid,
    author_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    discarded_at timestamp without time zone,
    pmt_name text,
    due_date timestamp without time zone,
    priority integer DEFAULT 0
);


--
-- Name: active_storage_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_attachments (
    name character varying NOT NULL,
    record_type character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    record_id uuid NOT NULL,
    blob_id uuid NOT NULL
);


--
-- Name: active_storage_blobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_blobs (
    key character varying NOT NULL,
    filename character varying NOT NULL,
    content_type character varying,
    metadata text,
    byte_size bigint NOT NULL,
    checksum character varying,
    created_at timestamp without time zone NOT NULL,
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    service_name character varying NOT NULL
);


--
-- Name: active_storage_variant_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_variant_records (
    integer_id bigint,
    blob_id uuid NOT NULL,
    variation_digest character varying NOT NULL,
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL
);


--
-- Name: aggregate_contents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.aggregate_contents (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    aggregate_id uuid NOT NULL,
    text text,
    rank integer
);


--
-- Name: aggregates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.aggregates (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    title character varying NOT NULL,
    description text,
    solution text,
    status integer,
    severity integer,
    report_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    kind integer DEFAULT 1 NOT NULL,
    discarded_at timestamp without time zone,
    rank integer DEFAULT 1 NOT NULL,
    scope text,
    visibility integer DEFAULT 0 NOT NULL,
    impact character varying,
    complexity character varying,
    from_aggregate_id uuid
);


--
-- Name: aggregates_actions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.aggregates_actions (
    aggregate_id uuid,
    action_id uuid,
    created_at timestamp without time zone
);


--
-- Name: aggregates_references; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.aggregates_references (
    aggregate_id uuid NOT NULL,
    reference_id uuid NOT NULL
);


--
-- Name: aggregates_vm_occurrences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.aggregates_vm_occurrences (
    vm_occurrence_id uuid NOT NULL,
    aggregate_id uuid NOT NULL
);


--
-- Name: aggregates_wa_occurrences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.aggregates_wa_occurrences (
    wa_occurrence_id uuid NOT NULL,
    aggregate_id uuid NOT NULL
);


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: assets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assets (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    description character varying,
    category integer NOT NULL,
    os character varying,
    confidentiality integer DEFAULT 0 NOT NULL,
    integrity integer DEFAULT 0 NOT NULL,
    availability integer DEFAULT 0 NOT NULL,
    account_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    discarded_at timestamp without time zone,
    import_id uuid
);


--
-- Name: assets_projects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assets_projects (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    asset_id uuid NOT NULL,
    project_id uuid NOT NULL
);


--
-- Name: assets_targets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assets_targets (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    asset_id uuid NOT NULL,
    target_id uuid NOT NULL
);


--
-- Name: brandings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.brandings (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    company_url character varying,
    linkedin_url character varying,
    twitter_url character varying,
    facebook_url character varying,
    pinterest_url character varying,
    youtube_url character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: certificates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.certificates (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    path character varying DEFAULT ''::character varying,
    stars_level integer DEFAULT 0,
    transparency_level integer DEFAULT 2,
    project_id uuid NOT NULL,
    discarded_at timestamp without time zone
);


--
-- Name: certificates_languages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.certificates_languages (
    language_id uuid NOT NULL,
    certificate_id uuid NOT NULL,
    sync_link character varying,
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL
);


--
-- Name: chat_configs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.chat_configs (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    chat_config_id uuid NOT NULL,
    channel_id character varying,
    bot_user_id character varying,
    workspace_name character varying,
    channel_name character varying,
    bot_name character varying,
    webhook_domain character varying
);


--
-- Name: clients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.clients (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    ref_identifier character varying,
    name character varying,
    web_url character varying,
    internal_type character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    discarded_at timestamp without time zone,
    otp_mandatory boolean DEFAULT false NOT NULL
);


--
-- Name: clients_contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.clients_contacts (
    client_id uuid NOT NULL,
    contact_id uuid NOT NULL
);


--
-- Name: clients_suppliers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.clients_suppliers (
    client_id uuid NOT NULL,
    supplier_id uuid NOT NULL
);


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comments (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    action_id uuid,
    comment text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    discarded_at timestamp without time zone,
    author_id uuid
);


--
-- Name: crons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.crons (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying,
    cronable_id uuid,
    cronable_type character varying,
    value character varying
);


--
-- Name: customizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customizations (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    key character varying,
    value character varying
);


--
-- Name: dependencies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dependencies (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    predecessor_id uuid NOT NULL,
    successor_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    discarded_at timestamp without time zone
);


--
-- Name: exploit_sources; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.exploit_sources (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    id_format character varying,
    exploits_root_url character varying
);


--
-- Name: exploits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.exploits (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    reference character varying,
    description character varying,
    link character varying,
    exploit_source_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: exploits_vulnerabilities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.exploits_vulnerabilities (
    exploit_id uuid NOT NULL,
    vulnerability_id uuid NOT NULL
);


--
-- Name: external_applications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.external_applications (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    app_id character varying,
    name character varying,
    encrypted_client_id character varying,
    encrypted_client_id_iv character varying,
    encrypted_client_secret character varying,
    encrypted_client_secret_iv character varying,
    encrypted_signing_secret character varying,
    encrypted_signing_secret_iv character varying,
    type character varying DEFAULT 'SlackApplication'::character varying NOT NULL
);


--
-- Name: groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.groups (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    otp_mandatory boolean DEFAULT false NOT NULL
);


--
-- Name: idp_configs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.idp_configs (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    active boolean DEFAULT true NOT NULL,
    idp_metadata_url character varying,
    idp_entity_id character varying,
    discarded_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: imports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.imports (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    importer_id uuid,
    status integer DEFAULT 0 NOT NULL,
    type character varying NOT NULL,
    import_type integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    scan_launch_id uuid,
    account_id uuid
);


--
-- Name: issues; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.issues (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    action_id uuid,
    ticketable_type character varying,
    ticketable_id uuid,
    status integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    pmt_reference character varying
);


--
-- Name: jira_configs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.jira_configs (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    jira_config_id uuid NOT NULL,
    context character varying DEFAULT ''::character varying NOT NULL,
    project_id character varying NOT NULL,
    status integer NOT NULL,
    expiration_date timestamp without time zone NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.jobs (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    creator_id uuid,
    resque_job_id character varying,
    progress_step integer DEFAULT 0,
    progress_steps integer,
    clazz character varying,
    status character varying DEFAULT 'init'::character varying,
    title character varying,
    stacktrace text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: jobs_subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.jobs_subscriptions (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    job_id uuid,
    subscriber_id uuid
);


--
-- Name: languages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.languages (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    iso character varying NOT NULL
);


--
-- Name: matrix42_configs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.matrix42_configs (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    matrix42_config_id uuid NOT NULL,
    status integer NOT NULL,
    default_ticket_type integer NOT NULL,
    need_refresh_at timestamp(6) without time zone,
    api_url character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: notes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notes (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    staff_id uuid NOT NULL,
    report_id uuid NOT NULL,
    title character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    discarded_at timestamp without time zone
);


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    version_id integer,
    created_at timestamp without time zone,
    subject integer
);


--
-- Name: notifications_subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications_subscriptions (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    notification_id uuid,
    subscriber_id uuid,
    state integer DEFAULT 0,
    discarded_at timestamp without time zone
);


--
-- Name: pentest_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pentest_reports (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    pentest_report_id uuid,
    tools text,
    exec_cond text,
    results text
);


--
-- Name: projects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.projects (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying,
    client_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    discarded_at timestamp without time zone,
    folder_name character varying DEFAULT ''::character varying,
    language_id uuid,
    auto_generate boolean DEFAULT false,
    auto_export boolean DEFAULT false,
    scan_regex character varying,
    notification_severity_threshold integer,
    auto_aggregate boolean DEFAULT true NOT NULL
);


--
-- Name: projects_suppliers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.projects_suppliers (
    project_id uuid NOT NULL,
    supplier_id uuid NOT NULL
);


--
-- Name: qualys_configs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.qualys_configs (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    qualys_config_id uuid,
    kind integer DEFAULT 0 NOT NULL
);


--
-- Name: qualys_vm_clients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.qualys_vm_clients (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    qualys_id character varying,
    qualys_name character varying,
    qualys_config_id uuid,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: qualys_vm_clients_teams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.qualys_vm_clients_teams (
    qualys_vm_client_id uuid NOT NULL,
    team_id uuid NOT NULL
);


--
-- Name: qualys_wa_clients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.qualys_wa_clients (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    qualys_id character varying,
    qualys_name character varying,
    qualys_config_id uuid,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: qualys_wa_clients_teams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.qualys_wa_clients_teams (
    qualys_wa_client_id uuid NOT NULL,
    team_id uuid NOT NULL
);


--
-- Name: references; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."references" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    top_id uuid NOT NULL,
    rank integer NOT NULL,
    name character varying NOT NULL
);


--
-- Name: report_exports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.report_exports (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    report_id uuid NOT NULL,
    exporter_id uuid NOT NULL,
    status integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: report_imports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.report_imports (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    report_id uuid NOT NULL,
    import_id uuid NOT NULL,
    auto_aggregate boolean DEFAULT true NOT NULL,
    auto_aggregate_mixing boolean DEFAULT true NOT NULL,
    scan_name character varying
);


--
-- Name: reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reports (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    staff_id uuid NOT NULL,
    project_id uuid NOT NULL,
    discarded_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    level integer DEFAULT 0,
    title character varying,
    edited_at date NOT NULL,
    introduction text,
    addendum text,
    language_id uuid,
    scoring_vm integer,
    scoring_wa integer,
    type character varying DEFAULT 'ScanReport'::character varying NOT NULL,
    scoring_vm_aggregate integer DEFAULT 0,
    scoring_wa_aggregate integer DEFAULT 0,
    subtitle character varying,
    aggregates_order_by text DEFAULT '---
- status
- severity
- visibility
- title
'::text,
    base_report_id uuid,
    signatory_id uuid,
    org_introduction text,
    purpose text
);


--
-- Name: reports_contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reports_contacts (
    report_id uuid NOT NULL,
    contact_id uuid NOT NULL
);


--
-- Name: reports_targets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reports_targets (
    target_id uuid NOT NULL,
    reports_vm_scans_id uuid NOT NULL
);


--
-- Name: reports_tops; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reports_tops (
    report_id uuid NOT NULL,
    top_id uuid NOT NULL
);


--
-- Name: reports_vm_scans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reports_vm_scans (
    vm_scan_id uuid NOT NULL,
    report_id uuid NOT NULL,
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL
);


--
-- Name: reports_wa_scans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reports_wa_scans (
    wa_scan_id uuid NOT NULL,
    report_id uuid NOT NULL,
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    web_app_url text
);


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying,
    resource_id uuid,
    resource_type character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    priority integer,
    group_id uuid,
    otp_mandatory boolean DEFAULT false NOT NULL
);


--
-- Name: scan_configurations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scan_configurations (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    launcher_id uuid NOT NULL,
    scanner integer DEFAULT 0 NOT NULL,
    scan_type character varying,
    scan_name character varying,
    target character varying NOT NULL,
    parameters character varying,
    auto_import boolean DEFAULT true,
    auto_aggregate boolean DEFAULT true NOT NULL,
    auto_aggregate_mixing boolean DEFAULT true NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: scan_launches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scan_launches (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    report_id uuid,
    launched_at timestamp without time zone,
    terminated_at timestamp without time zone,
    termination_msg character varying,
    status integer DEFAULT 0 NOT NULL,
    kube_scan_id character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    csis_job_id uuid,
    scan_configuration_id uuid
);


--
-- Name: scan_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scan_reports (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    scan_report_id uuid,
    vm_introduction text,
    wa_introduction text
);


--
-- Name: scheduled_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scheduled_jobs (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying DEFAULT ''::character varying NOT NULL,
    configuration jsonb,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: scheduled_scans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scheduled_scans (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    project_id uuid NOT NULL,
    scan_configuration_id uuid NOT NULL,
    report_action integer DEFAULT 0 NOT NULL,
    discarded_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: sellsy_configs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sellsy_configs (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    encrypted_consumer_token character varying NOT NULL,
    encrypted_user_token character varying NOT NULL,
    encrypted_consumer_secret character varying NOT NULL,
    encrypted_user_secret character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    name character varying NOT NULL,
    encrypted_consumer_token_iv character varying NOT NULL,
    encrypted_user_token_iv character varying NOT NULL,
    encrypted_consumer_secret_iv character varying NOT NULL,
    encrypted_user_secret_iv character varying NOT NULL
);


--
-- Name: servicenow_configs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.servicenow_configs (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    servicenow_config_id uuid NOT NULL,
    status integer NOT NULL,
    need_refresh_at timestamp without time zone,
    fixed_vuln character varying NOT NULL,
    accepted_risk character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: staffs_teams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.staffs_teams (
    staff_id uuid NOT NULL,
    team_id uuid NOT NULL
);


--
-- Name: statistics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.statistics (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    scans_count integer DEFAULT 0,
    level_average integer DEFAULT 0,
    current_level integer DEFAULT 0,
    nof_excellent integer DEFAULT 0,
    nof_very_good integer DEFAULT 0,
    nof_good integer DEFAULT 0,
    nof_satisfactory integer DEFAULT 0,
    score integer DEFAULT 0,
    project_id uuid NOT NULL,
    discarded_at timestamp without time zone,
    scan_reports_count integer DEFAULT 0,
    nof_in_progress integer DEFAULT 0,
    blazon integer DEFAULT 0,
    pentest_reports_count integer DEFAULT 0,
    action_plan_reports_count integer
);


--
-- Name: targets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.targets (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    ip inet,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    name character varying,
    kind character varying DEFAULT 'VmTarget'::character varying NOT NULL,
    reference_id character varying,
    discarded_at timestamp without time zone,
    url character varying
);


--
-- Name: targets_scans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.targets_scans (
    target_id uuid NOT NULL,
    scan_id uuid NOT NULL,
    scan_type character varying NOT NULL
);


--
-- Name: teams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.teams (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    discarded_at timestamp without time zone,
    otp_mandatory boolean DEFAULT false NOT NULL
);


--
-- Name: teams_projects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.teams_projects (
    team_id uuid,
    project_id uuid,
    created_at timestamp without time zone
);


--
-- Name: tops; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tops (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    full_name character varying NOT NULL,
    email character varying NOT NULL,
    notification_email character varying,
    encrypted_password character varying,
    public_key text,
    state integer DEFAULT 0,
    language_id uuid,
    default_view character varying,
    ref_identifier character varying,
    avatar_url character varying,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    provider character varying,
    uid character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    discarded_at timestamp without time zone,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    confirmation_token character varying,
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying,
    failed_attempts integer DEFAULT 0 NOT NULL,
    unlock_token character varying,
    locked_at timestamp without time zone,
    second_factor_attempts_count integer DEFAULT 0,
    encrypted_otp_secret_key character varying,
    encrypted_otp_secret_key_iv character varying,
    encrypted_otp_secret_key_salt character varying,
    direct_otp character varying,
    direct_otp_sent_at timestamp without time zone,
    totp_timestamp timestamp without time zone,
    otp_activated_at timestamp without time zone,
    totp_configuration_token character varying,
    display_submenu_direction integer DEFAULT 0,
    otp_mandatory boolean DEFAULT false NOT NULL,
    send_mail_on text[] DEFAULT '{exceeding_severity_threshold}'::text[],
    notify_on text[] DEFAULT '{action_state_update,comment_creation,export_generation,scan_launch_done,scan_created,scan_destroyed,exceeding_severity_threshold}'::text[]
);


--
-- Name: users_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_groups (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    group_id uuid NOT NULL,
    dashboard_default_card character varying DEFAULT 'reports'::character varying,
    current boolean DEFAULT false NOT NULL
);


--
-- Name: users_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users_roles (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    role_id uuid NOT NULL
);


--
-- Name: versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.versions (
    id bigint NOT NULL,
    item_type character varying NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object text,
    created_at timestamp(6) without time zone,
    object_changes text,
    item_id uuid
)
PARTITION BY RANGE (created_at);


--
-- Name: versions_range_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.versions_range_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: versions_range_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.versions_range_records_id_seq OWNED BY public.versions.id;


--
-- Name: versions_range_records_template; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.versions_range_records_template (
    id bigint DEFAULT nextval('public.versions_range_records_id_seq'::regclass) NOT NULL,
    item_type character varying NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object text,
    created_at timestamp(6) without time zone,
    object_changes text,
    item_id uuid
);


--
-- Name: versions_y2023_m01; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.versions_y2023_m01 (
    id bigint DEFAULT nextval('public.versions_range_records_id_seq'::regclass) NOT NULL,
    item_type character varying NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object text,
    created_at timestamp(6) without time zone,
    object_changes text,
    item_id uuid
);


--
-- Name: versions_y2023_m02; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.versions_y2023_m02 (
    id bigint DEFAULT nextval('public.versions_range_records_id_seq'::regclass) NOT NULL,
    item_type character varying NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object text,
    created_at timestamp(6) without time zone,
    object_changes text,
    item_id uuid
);


--
-- Name: versions_y2023_m03; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.versions_y2023_m03 (
    id bigint DEFAULT nextval('public.versions_range_records_id_seq'::regclass) NOT NULL,
    item_type character varying NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object text,
    created_at timestamp(6) without time zone,
    object_changes text,
    item_id uuid
);


--
-- Name: versions_y2023_m04; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.versions_y2023_m04 (
    id bigint DEFAULT nextval('public.versions_range_records_id_seq'::regclass) NOT NULL,
    item_type character varying NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object text,
    created_at timestamp(6) without time zone,
    object_changes text,
    item_id uuid
);


--
-- Name: versions_y2023_m05; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.versions_y2023_m05 (
    id bigint DEFAULT nextval('public.versions_range_records_id_seq'::regclass) NOT NULL,
    item_type character varying NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object text,
    created_at timestamp(6) without time zone,
    object_changes text,
    item_id uuid
);


--
-- Name: versions_y2023_m06; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.versions_y2023_m06 (
    id bigint DEFAULT nextval('public.versions_range_records_id_seq'::regclass) NOT NULL,
    item_type character varying NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object text,
    created_at timestamp(6) without time zone,
    object_changes text,
    item_id uuid
);


--
-- Name: versions_y2023_m07; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.versions_y2023_m07 (
    id bigint DEFAULT nextval('public.versions_range_records_id_seq'::regclass) NOT NULL,
    item_type character varying NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object text,
    created_at timestamp(6) without time zone,
    object_changes text,
    item_id uuid
);


--
-- Name: versions_y2023_m08; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.versions_y2023_m08 (
    id bigint DEFAULT nextval('public.versions_range_records_id_seq'::regclass) NOT NULL,
    item_type character varying NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object text,
    created_at timestamp(6) without time zone,
    object_changes text,
    item_id uuid
);


--
-- Name: versions_y2023_m09; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.versions_y2023_m09 (
    id bigint DEFAULT nextval('public.versions_range_records_id_seq'::regclass) NOT NULL,
    item_type character varying NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object text,
    created_at timestamp(6) without time zone,
    object_changes text,
    item_id uuid
);


--
-- Name: versions_y2023_m10; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.versions_y2023_m10 (
    id bigint DEFAULT nextval('public.versions_range_records_id_seq'::regclass) NOT NULL,
    item_type character varying NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object text,
    created_at timestamp(6) without time zone,
    object_changes text,
    item_id uuid
);


--
-- Name: versions_y2023_m11; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.versions_y2023_m11 (
    id bigint DEFAULT nextval('public.versions_range_records_id_seq'::regclass) NOT NULL,
    item_type character varying NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object text,
    created_at timestamp(6) without time zone,
    object_changes text,
    item_id uuid
);


--
-- Name: versions_y2023_m12; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.versions_y2023_m12 (
    id bigint DEFAULT nextval('public.versions_range_records_id_seq'::regclass) NOT NULL,
    item_type character varying NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object text,
    created_at timestamp(6) without time zone,
    object_changes text,
    item_id uuid
);


--
-- Name: versions_y2024_m01; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.versions_y2024_m01 (
    id bigint DEFAULT nextval('public.versions_range_records_id_seq'::regclass) NOT NULL,
    item_type character varying NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object text,
    created_at timestamp(6) without time zone,
    object_changes text,
    item_id uuid
);


--
-- Name: versions_y2024_m02; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.versions_y2024_m02 (
    id bigint DEFAULT nextval('public.versions_range_records_id_seq'::regclass) NOT NULL,
    item_type character varying NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    object text,
    created_at timestamp(6) without time zone,
    object_changes text,
    item_id uuid
);


--
-- Name: vm_occurrences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vm_occurrences (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    result text,
    netbios character varying,
    fqdn character varying,
    vulnerability_id uuid,
    scan_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    false_positive integer DEFAULT 0 NOT NULL,
    ip inet
);


--
-- Name: vm_scans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vm_scans (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    reference character varying,
    scan_type character varying,
    status character varying,
    name character varying,
    launched_by character varying,
    option_title character varying,
    processed numeric,
    option_flag numeric,
    target inet,
    duration interval,
    launched_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    qualys_vm_client_id uuid,
    account_id uuid,
    import_id uuid
);


--
-- Name: vulnerabilities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vulnerabilities (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    qid character varying NOT NULL,
    cve_id text[] DEFAULT '{}'::text[],
    title character varying NOT NULL,
    category character varying NOT NULL,
    bugtraqs character varying[],
    cvss character varying,
    modified timestamp without time zone NOT NULL,
    published timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    solution text,
    diagnosis text,
    internal_type character varying,
    severity integer,
    patchable integer,
    consequence text,
    pci_flag integer,
    remote integer,
    additional_info text,
    cvss_vector character varying,
    kb_type character varying,
    kind integer,
    import_id uuid,
    cvss_version character varying DEFAULT '3'::character varying,
    exploitability_score character varying,
    impact_score character varying,
    osvdb character varying
);


--
-- Name: wa_occurrences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wa_occurrences (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    result text,
    uri character varying,
    vulnerability_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    scan_id uuid,
    param character varying,
    content character varying,
    false_positive integer DEFAULT 0 NOT NULL,
    payload text,
    data text
);


--
-- Name: wa_scans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wa_scans (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    internal_id character varying,
    name character varying,
    reference character varying,
    scan_type character varying,
    mode character varying,
    multi character varying,
    scanner_appliance_type character varying,
    cancel_option character varying,
    profile_id integer,
    profile_name character varying,
    launched_by character varying,
    status character varying,
    links_crawled character varying,
    nb_requests numeric,
    results_status character varying,
    auth_status character varying,
    os character varying,
    crawl_duration interval,
    test_duration interval,
    launched_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    qualys_wa_client_id uuid,
    account_id uuid,
    import_id uuid
);


--
-- Name: versions_y2023_m01; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions ATTACH PARTITION public.versions_y2023_m01 FOR VALUES FROM ('2022-12-31 23:00:00') TO ('2023-01-31 23:00:00');


--
-- Name: versions_y2023_m02; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions ATTACH PARTITION public.versions_y2023_m02 FOR VALUES FROM ('2023-01-31 23:00:00') TO ('2023-02-28 23:00:00');


--
-- Name: versions_y2023_m03; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions ATTACH PARTITION public.versions_y2023_m03 FOR VALUES FROM ('2023-02-28 23:00:00') TO ('2023-03-31 22:00:00');


--
-- Name: versions_y2023_m04; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions ATTACH PARTITION public.versions_y2023_m04 FOR VALUES FROM ('2023-03-31 22:00:00') TO ('2023-04-30 22:00:00');


--
-- Name: versions_y2023_m05; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions ATTACH PARTITION public.versions_y2023_m05 FOR VALUES FROM ('2023-04-30 22:00:00') TO ('2023-05-31 22:00:00');


--
-- Name: versions_y2023_m06; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions ATTACH PARTITION public.versions_y2023_m06 FOR VALUES FROM ('2023-05-31 22:00:00') TO ('2023-06-30 22:00:00');


--
-- Name: versions_y2023_m07; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions ATTACH PARTITION public.versions_y2023_m07 FOR VALUES FROM ('2023-06-30 22:00:00') TO ('2023-07-31 22:00:00');


--
-- Name: versions_y2023_m08; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions ATTACH PARTITION public.versions_y2023_m08 FOR VALUES FROM ('2023-07-31 22:00:00') TO ('2023-08-31 22:00:00');


--
-- Name: versions_y2023_m09; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions ATTACH PARTITION public.versions_y2023_m09 FOR VALUES FROM ('2023-09-01 00:00:00') TO ('2023-10-01 00:00:00');


--
-- Name: versions_y2023_m10; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions ATTACH PARTITION public.versions_y2023_m10 FOR VALUES FROM ('2023-10-01 00:00:00') TO ('2023-11-01 00:00:00');


--
-- Name: versions_y2023_m11; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions ATTACH PARTITION public.versions_y2023_m11 FOR VALUES FROM ('2023-11-01 00:00:00') TO ('2023-12-01 00:00:00');


--
-- Name: versions_y2023_m12; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions ATTACH PARTITION public.versions_y2023_m12 FOR VALUES FROM ('2023-12-01 00:00:00') TO ('2024-01-01 00:00:00');


--
-- Name: versions_y2024_m01; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions ATTACH PARTITION public.versions_y2024_m01 FOR VALUES FROM ('2024-01-01 00:00:00') TO ('2024-02-01 00:00:00');


--
-- Name: versions_y2024_m02; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions ATTACH PARTITION public.versions_y2024_m02 FOR VALUES FROM ('2024-02-01 00:00:00') TO ('2024-03-01 00:00:00');


--
-- Name: versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions ALTER COLUMN id SET DEFAULT nextval('public.versions_range_records_id_seq'::regclass);


--
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: accounts_teams accounts_teams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts_teams
    ADD CONSTRAINT accounts_teams_pkey PRIMARY KEY (id);


--
-- Name: accounts_users accounts_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts_users
    ADD CONSTRAINT accounts_users_pkey PRIMARY KEY (id);


--
-- Name: action_text_rich_texts action_text_rich_texts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.action_text_rich_texts
    ADD CONSTRAINT action_text_rich_texts_pkey PRIMARY KEY (id);


--
-- Name: actions actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actions
    ADD CONSTRAINT actions_pkey PRIMARY KEY (id);


--
-- Name: active_storage_attachments active_storage_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT active_storage_attachments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_blobs active_storage_blobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs
    ADD CONSTRAINT active_storage_blobs_pkey PRIMARY KEY (id);


--
-- Name: active_storage_variant_records active_storage_variant_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT active_storage_variant_records_pkey PRIMARY KEY (id);


--
-- Name: aggregate_contents aggregate_contents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aggregate_contents
    ADD CONSTRAINT aggregate_contents_pkey PRIMARY KEY (id);


--
-- Name: aggregates aggregates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aggregates
    ADD CONSTRAINT aggregates_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: assets assets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assets
    ADD CONSTRAINT assets_pkey PRIMARY KEY (id);


--
-- Name: assets_projects assets_projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assets_projects
    ADD CONSTRAINT assets_projects_pkey PRIMARY KEY (id);


--
-- Name: assets_targets assets_targets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assets_targets
    ADD CONSTRAINT assets_targets_pkey PRIMARY KEY (id);


--
-- Name: brandings brandings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.brandings
    ADD CONSTRAINT brandings_pkey PRIMARY KEY (id);


--
-- Name: certificates_languages certificates_languages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certificates_languages
    ADD CONSTRAINT certificates_languages_pkey PRIMARY KEY (id);


--
-- Name: certificates certificates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certificates
    ADD CONSTRAINT certificates_pkey PRIMARY KEY (id);


--
-- Name: chat_configs chat_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chat_configs
    ADD CONSTRAINT chat_configs_pkey PRIMARY KEY (id);


--
-- Name: clients clients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_pkey PRIMARY KEY (id);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: crons crons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crons
    ADD CONSTRAINT crons_pkey PRIMARY KEY (id);


--
-- Name: customizations customizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customizations
    ADD CONSTRAINT customizations_pkey PRIMARY KEY (id);


--
-- Name: dependencies dependencies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dependencies
    ADD CONSTRAINT dependencies_pkey PRIMARY KEY (id);


--
-- Name: exploit_sources exploit_sources_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exploit_sources
    ADD CONSTRAINT exploit_sources_pkey PRIMARY KEY (id);


--
-- Name: exploits exploits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exploits
    ADD CONSTRAINT exploits_pkey PRIMARY KEY (id);


--
-- Name: external_applications external_applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.external_applications
    ADD CONSTRAINT external_applications_pkey PRIMARY KEY (id);


--
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: idp_configs idp_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.idp_configs
    ADD CONSTRAINT idp_configs_pkey PRIMARY KEY (id);


--
-- Name: imports imports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.imports
    ADD CONSTRAINT imports_pkey PRIMARY KEY (id);


--
-- Name: aggregates index_aggregates_on_report_id_and_kind_and_rank; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aggregates
    ADD CONSTRAINT index_aggregates_on_report_id_and_kind_and_rank UNIQUE (report_id, kind, rank) DEFERRABLE;


--
-- Name: issues issues_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.issues
    ADD CONSTRAINT issues_pkey PRIMARY KEY (id);


--
-- Name: jira_configs jira_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jira_configs
    ADD CONSTRAINT jira_configs_pkey PRIMARY KEY (id);


--
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: jobs_subscriptions jobs_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jobs_subscriptions
    ADD CONSTRAINT jobs_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: languages languages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.languages
    ADD CONSTRAINT languages_pkey PRIMARY KEY (id);


--
-- Name: matrix42_configs matrix42_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.matrix42_configs
    ADD CONSTRAINT matrix42_configs_pkey PRIMARY KEY (id);


--
-- Name: notes notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT notes_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: notifications_subscriptions notifications_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications_subscriptions
    ADD CONSTRAINT notifications_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: pentest_reports pentest_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pentest_reports
    ADD CONSTRAINT pentest_reports_pkey PRIMARY KEY (id);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: qualys_configs qualys_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.qualys_configs
    ADD CONSTRAINT qualys_configs_pkey PRIMARY KEY (id);


--
-- Name: qualys_vm_clients qualys_vm_clients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.qualys_vm_clients
    ADD CONSTRAINT qualys_vm_clients_pkey PRIMARY KEY (id);


--
-- Name: qualys_wa_clients qualys_wa_clients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.qualys_wa_clients
    ADD CONSTRAINT qualys_wa_clients_pkey PRIMARY KEY (id);


--
-- Name: references references_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."references"
    ADD CONSTRAINT references_pkey PRIMARY KEY (id);


--
-- Name: report_exports report_exports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_exports
    ADD CONSTRAINT report_exports_pkey PRIMARY KEY (id);


--
-- Name: report_imports report_imports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_imports
    ADD CONSTRAINT report_imports_pkey PRIMARY KEY (id);


--
-- Name: reports reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT reports_pkey PRIMARY KEY (id);


--
-- Name: reports_vm_scans reports_vm_scans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports_vm_scans
    ADD CONSTRAINT reports_vm_scans_pkey PRIMARY KEY (id);


--
-- Name: reports_wa_scans reports_wa_scans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports_wa_scans
    ADD CONSTRAINT reports_wa_scans_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: scan_configurations scan_configurations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scan_configurations
    ADD CONSTRAINT scan_configurations_pkey PRIMARY KEY (id);


--
-- Name: scan_launches scan_launches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scan_launches
    ADD CONSTRAINT scan_launches_pkey PRIMARY KEY (id);


--
-- Name: scan_reports scan_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scan_reports
    ADD CONSTRAINT scan_reports_pkey PRIMARY KEY (id);


--
-- Name: scheduled_jobs scheduled_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduled_jobs
    ADD CONSTRAINT scheduled_jobs_pkey PRIMARY KEY (id);


--
-- Name: scheduled_scans scheduled_scans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduled_scans
    ADD CONSTRAINT scheduled_scans_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sellsy_configs sellsy_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sellsy_configs
    ADD CONSTRAINT sellsy_configs_pkey PRIMARY KEY (id);


--
-- Name: servicenow_configs servicenow_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.servicenow_configs
    ADD CONSTRAINT servicenow_configs_pkey PRIMARY KEY (id);


--
-- Name: statistics statistics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.statistics
    ADD CONSTRAINT statistics_pkey PRIMARY KEY (id);


--
-- Name: targets targets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.targets
    ADD CONSTRAINT targets_pkey PRIMARY KEY (id);


--
-- Name: teams teams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_pkey PRIMARY KEY (id);


--
-- Name: tops tops_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tops
    ADD CONSTRAINT tops_pkey PRIMARY KEY (id);


--
-- Name: users_groups users_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_groups
    ADD CONSTRAINT users_groups_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users_roles users_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_roles
    ADD CONSTRAINT users_roles_pkey PRIMARY KEY (id);


--
-- Name: versions_range_records_template versions_range_records_template_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions_range_records_template
    ADD CONSTRAINT versions_range_records_template_pkey PRIMARY KEY (id);


--
-- Name: versions_y2023_m01 versions_y2023_m01_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions_y2023_m01
    ADD CONSTRAINT versions_y2023_m01_pkey PRIMARY KEY (id);


--
-- Name: versions_y2023_m02 versions_y2023_m02_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions_y2023_m02
    ADD CONSTRAINT versions_y2023_m02_pkey PRIMARY KEY (id);


--
-- Name: versions_y2023_m03 versions_y2023_m03_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions_y2023_m03
    ADD CONSTRAINT versions_y2023_m03_pkey PRIMARY KEY (id);


--
-- Name: versions_y2023_m04 versions_y2023_m04_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions_y2023_m04
    ADD CONSTRAINT versions_y2023_m04_pkey PRIMARY KEY (id);


--
-- Name: versions_y2023_m05 versions_y2023_m05_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions_y2023_m05
    ADD CONSTRAINT versions_y2023_m05_pkey PRIMARY KEY (id);


--
-- Name: versions_y2023_m06 versions_y2023_m06_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions_y2023_m06
    ADD CONSTRAINT versions_y2023_m06_pkey PRIMARY KEY (id);


--
-- Name: versions_y2023_m07 versions_y2023_m07_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions_y2023_m07
    ADD CONSTRAINT versions_y2023_m07_pkey PRIMARY KEY (id);


--
-- Name: versions_y2023_m08 versions_y2023_m08_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions_y2023_m08
    ADD CONSTRAINT versions_y2023_m08_pkey PRIMARY KEY (id);


--
-- Name: versions_y2023_m09 versions_y2023_m09_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions_y2023_m09
    ADD CONSTRAINT versions_y2023_m09_pkey PRIMARY KEY (id);


--
-- Name: versions_y2023_m10 versions_y2023_m10_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions_y2023_m10
    ADD CONSTRAINT versions_y2023_m10_pkey PRIMARY KEY (id);


--
-- Name: versions_y2023_m11 versions_y2023_m11_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions_y2023_m11
    ADD CONSTRAINT versions_y2023_m11_pkey PRIMARY KEY (id);


--
-- Name: versions_y2023_m12 versions_y2023_m12_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions_y2023_m12
    ADD CONSTRAINT versions_y2023_m12_pkey PRIMARY KEY (id);


--
-- Name: versions_y2024_m01 versions_y2024_m01_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions_y2024_m01
    ADD CONSTRAINT versions_y2024_m01_pkey PRIMARY KEY (id);


--
-- Name: versions_y2024_m02 versions_y2024_m02_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions_y2024_m02
    ADD CONSTRAINT versions_y2024_m02_pkey PRIMARY KEY (id);


--
-- Name: vm_occurrences vm_occurrences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vm_occurrences
    ADD CONSTRAINT vm_occurrences_pkey PRIMARY KEY (id);


--
-- Name: vm_scans vm_scans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vm_scans
    ADD CONSTRAINT vm_scans_pkey PRIMARY KEY (id);


--
-- Name: vulnerabilities vulnerabilities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vulnerabilities
    ADD CONSTRAINT vulnerabilities_pkey PRIMARY KEY (id);


--
-- Name: wa_occurrences wa_occurrences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wa_occurrences
    ADD CONSTRAINT wa_occurrences_pkey PRIMARY KEY (id);


--
-- Name: wa_scans wa_scans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wa_scans
    ADD CONSTRAINT wa_scans_pkey PRIMARY KEY (id);


--
-- Name: dependencies_idx_pred_succ; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX dependencies_idx_pred_succ ON public.dependencies USING btree (successor_id, predecessor_id);


--
-- Name: index_accounts_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_accounts_on_discarded_at ON public.accounts USING btree (discarded_at);


--
-- Name: index_accounts_teams; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_accounts_teams ON public.accounts_teams USING btree (account_id, team_id);


--
-- Name: index_accounts_users; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_accounts_users ON public.accounts_users USING btree (account_id, user_id);


--
-- Name: index_action_text_rich_texts_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_action_text_rich_texts_uniqueness ON public.action_text_rich_texts USING btree (record_type, record_id, name);


--
-- Name: index_actions_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_actions_on_discarded_at ON public.actions USING btree (discarded_at);


--
-- Name: index_active_storage_blobs_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_blobs_on_key ON public.active_storage_blobs USING btree (key);


--
-- Name: index_active_storage_variant_records_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_variant_records_uniqueness ON public.active_storage_variant_records USING btree (blob_id, variation_digest);


--
-- Name: index_aggregates_actions; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_aggregates_actions ON public.aggregates_actions USING btree (aggregate_id, action_id);


--
-- Name: index_aggregates_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_aggregates_on_discarded_at ON public.aggregates USING btree (discarded_at);


--
-- Name: index_aggregates_vm_occurences; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_aggregates_vm_occurences ON public.aggregates_vm_occurrences USING btree (vm_occurrence_id, aggregate_id);


--
-- Name: index_aggregates_wa_occurences; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_aggregates_wa_occurences ON public.aggregates_wa_occurrences USING btree (wa_occurrence_id, aggregate_id);


--
-- Name: index_assets_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assets_on_discarded_at ON public.assets USING btree (discarded_at);


--
-- Name: index_assets_projects_on_asset_id_and_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_assets_projects_on_asset_id_and_project_id ON public.assets_projects USING btree (asset_id, project_id);


--
-- Name: index_assets_targets_on_asset_id_and_target_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_assets_targets_on_asset_id_and_target_id ON public.assets_targets USING btree (asset_id, target_id);


--
-- Name: index_certificates_languages_on_certificate_id_and_language_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_certificates_languages_on_certificate_id_and_language_id ON public.certificates_languages USING btree (certificate_id, language_id);


--
-- Name: index_certificates_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_certificates_on_discarded_at ON public.certificates USING btree (discarded_at);


--
-- Name: index_clients_contacts_on_contact_id_and_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_clients_contacts_on_contact_id_and_client_id ON public.clients_contacts USING btree (contact_id, client_id);


--
-- Name: index_clients_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_clients_on_discarded_at ON public.clients USING btree (discarded_at);


--
-- Name: index_clients_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_clients_on_name ON public.clients USING btree (name);


--
-- Name: index_comments_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_discarded_at ON public.comments USING btree (discarded_at);


--
-- Name: index_crons_on_name_and_res_type_and_res_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_crons_on_name_and_res_type_and_res_id ON public.crons USING btree (name, cronable_type, cronable_id);


--
-- Name: index_customizations_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_customizations_on_key ON public.customizations USING btree (key);


--
-- Name: index_dependencies_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dependencies_on_discarded_at ON public.dependencies USING btree (discarded_at);


--
-- Name: index_exploits_on_reference_and_link_and_description; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_exploits_on_reference_and_link_and_description ON public.exploits USING btree (reference, link, description);


--
-- Name: index_exploits_vuln_on_exploit_id_and_vuln_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_exploits_vuln_on_exploit_id_and_vuln_id ON public.exploits_vulnerabilities USING btree (exploit_id, vulnerability_id);


--
-- Name: index_groups_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_groups_on_name ON public.groups USING btree (name);


--
-- Name: index_idp_configs_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_idp_configs_on_name ON public.idp_configs USING btree (name);


--
-- Name: index_issues_on_ticketable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_issues_on_ticketable ON public.issues USING btree (ticketable_type, ticketable_id);


--
-- Name: index_jobs_on_resque_job_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_resque_job_id ON public.jobs USING btree (resque_job_id);


--
-- Name: index_notes_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notes_on_discarded_at ON public.notes USING btree (discarded_at);


--
-- Name: index_notifications_on_version_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_notifications_on_version_id ON public.notifications USING btree (version_id);


--
-- Name: index_notifications_subscriptions; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_notifications_subscriptions ON public.notifications_subscriptions USING btree (notification_id, subscriber_id);


--
-- Name: index_notifications_subscriptions_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notifications_subscriptions_on_discarded_at ON public.notifications_subscriptions USING btree (discarded_at);


--
-- Name: index_projects_on_client_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_projects_on_client_id_and_name ON public.projects USING btree (client_id, name);


--
-- Name: index_projects_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_discarded_at ON public.projects USING btree (discarded_at);


--
-- Name: index_projects_suppliers_on_project_id_and_supplier_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_projects_suppliers_on_project_id_and_supplier_id ON public.projects_suppliers USING btree (project_id, supplier_id);


--
-- Name: index_qualys_vm_clients_teams; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_qualys_vm_clients_teams ON public.qualys_vm_clients_teams USING btree (qualys_vm_client_id, team_id);


--
-- Name: index_qualys_wa_clients_teams; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_qualys_wa_clients_teams ON public.qualys_wa_clients_teams USING btree (qualys_wa_client_id, team_id);


--
-- Name: index_reports_contacts_on_contact_id_and_report_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_reports_contacts_on_contact_id_and_report_id ON public.reports_contacts USING btree (contact_id, report_id);


--
-- Name: index_reports_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reports_on_discarded_at ON public.reports USING btree (discarded_at);


--
-- Name: index_reports_on_project_id_and_edited_at_and_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_reports_on_project_id_and_edited_at_and_discarded_at ON public.reports USING btree (project_id, edited_at, discarded_at);


--
-- Name: index_reports_targets_on_target_id_and_reports_vm_scans_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_reports_targets_on_target_id_and_reports_vm_scans_id ON public.reports_targets USING btree (target_id, reports_vm_scans_id);


--
-- Name: index_reports_vm_scans_on_vm_scan_id_and_report_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_reports_vm_scans_on_vm_scan_id_and_report_id ON public.reports_vm_scans USING btree (vm_scan_id, report_id);


--
-- Name: index_reports_wa_scans_on_wa_scan_id_and_report_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_reports_wa_scans_on_wa_scan_id_and_report_id ON public.reports_wa_scans USING btree (wa_scan_id, report_id);


--
-- Name: index_roles_on_name_and_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_roles_on_name_and_group_id ON public.roles USING btree (name, group_id);


--
-- Name: index_roles_on_name_and_grp_id_and_res_type_and_res_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_roles_on_name_and_grp_id_and_res_type_and_res_id ON public.roles USING btree (name, group_id, resource_type, resource_id);


--
-- Name: index_scheduled_scans_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_scheduled_scans_on_discarded_at ON public.scheduled_scans USING btree (discarded_at);


--
-- Name: index_staffs_teams_on_team_id_and_staff_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_staffs_teams_on_team_id_and_staff_id ON public.staffs_teams USING btree (team_id, staff_id);


--
-- Name: index_statistics_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_statistics_on_discarded_at ON public.statistics USING btree (discarded_at);


--
-- Name: index_targets_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_targets_on_discarded_at ON public.targets USING btree (discarded_at);


--
-- Name: index_targets_scans_on_target_id_and_scan_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_targets_scans_on_target_id_and_scan_id ON public.targets_scans USING btree (target_id, scan_id);


--
-- Name: index_teams_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_teams_on_discarded_at ON public.teams USING btree (discarded_at);


--
-- Name: index_teams_projects; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_teams_projects ON public.teams_projects USING btree (team_id, project_id);


--
-- Name: index_users_groups_on_group_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_groups_on_group_id_and_user_id ON public.users_groups USING btree (group_id, user_id);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON public.users USING btree (confirmation_token);


--
-- Name: index_users_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_discarded_at ON public.users USING btree (discarded_at);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_encrypted_otp_secret_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_encrypted_otp_secret_key ON public.users USING btree (encrypted_otp_secret_key);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: index_users_on_unlock_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_unlock_token ON public.users USING btree (unlock_token);


--
-- Name: index_users_roles_on_user_id_and_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_roles_on_user_id_and_role_id ON public.users_roles USING btree (user_id, role_id);


--
-- Name: index_versions_event; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_event ON ONLY public.versions USING btree (event);


--
-- Name: index_versions_event_177765f; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_event_177765f ON public.versions_y2023_m08 USING btree (event);


--
-- Name: index_versions_event_1bf0c9a; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_event_1bf0c9a ON public.versions_y2023_m01 USING btree (event);


--
-- Name: index_versions_event_44d370e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_event_44d370e ON public.versions_y2023_m03 USING btree (event);


--
-- Name: index_versions_event_4dc39ba; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_event_4dc39ba ON public.versions_y2023_m05 USING btree (event);


--
-- Name: index_versions_event_5d3b480; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_event_5d3b480 ON public.versions_y2023_m06 USING btree (event);


--
-- Name: index_versions_event_716484f; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_event_716484f ON public.versions_y2023_m02 USING btree (event);


--
-- Name: index_versions_event_b414805; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_event_b414805 ON public.versions_y2023_m04 USING btree (event);


--
-- Name: index_versions_event_e4a326e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_event_e4a326e ON public.versions_y2023_m07 USING btree (event);


--
-- Name: index_versions_item_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_item_type ON ONLY public.versions USING btree (item_type);


--
-- Name: index_versions_item_type_177765f; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_item_type_177765f ON public.versions_y2023_m08 USING btree (item_type);


--
-- Name: index_versions_item_type_1bf0c9a; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_item_type_1bf0c9a ON public.versions_y2023_m01 USING btree (item_type);


--
-- Name: index_versions_item_type_44d370e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_item_type_44d370e ON public.versions_y2023_m03 USING btree (item_type);


--
-- Name: index_versions_item_type_4dc39ba; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_item_type_4dc39ba ON public.versions_y2023_m05 USING btree (item_type);


--
-- Name: index_versions_item_type_5d3b480; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_item_type_5d3b480 ON public.versions_y2023_m06 USING btree (item_type);


--
-- Name: index_versions_item_type_716484f; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_item_type_716484f ON public.versions_y2023_m02 USING btree (item_type);


--
-- Name: index_versions_item_type_b414805; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_item_type_b414805 ON public.versions_y2023_m04 USING btree (item_type);


--
-- Name: index_versions_item_type_e4a326e; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_item_type_e4a326e ON public.versions_y2023_m07 USING btree (item_type);


--
-- Name: index_vm_scans_on_reference; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_vm_scans_on_reference ON public.vm_scans USING btree (reference);


--
-- Name: index_vulnerabilities_on_qid_and_kb_type; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_vulnerabilities_on_qid_and_kb_type ON public.vulnerabilities USING btree (kb_type, qid);


--
-- Name: index_wa_scans_on_launched_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wa_scans_on_launched_by ON public.wa_scans USING btree (launched_by);


--
-- Name: index_wa_scans_on_reference; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_wa_scans_on_reference ON public.wa_scans USING btree (reference);


--
-- Name: references_idx_name_top_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX references_idx_name_top_id ON public."references" USING btree (name, top_id);


--
-- Name: references_idx_rank_top_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX references_idx_rank_top_id ON public."references" USING btree (rank, top_id);


--
-- Name: versions_y2023_m09_event_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX versions_y2023_m09_event_idx ON public.versions_y2023_m09 USING btree (event);


--
-- Name: versions_y2023_m09_item_type_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX versions_y2023_m09_item_type_idx ON public.versions_y2023_m09 USING btree (item_type);


--
-- Name: versions_y2023_m10_event_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX versions_y2023_m10_event_idx ON public.versions_y2023_m10 USING btree (event);


--
-- Name: versions_y2023_m10_item_type_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX versions_y2023_m10_item_type_idx ON public.versions_y2023_m10 USING btree (item_type);


--
-- Name: versions_y2023_m11_event_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX versions_y2023_m11_event_idx ON public.versions_y2023_m11 USING btree (event);


--
-- Name: versions_y2023_m11_item_type_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX versions_y2023_m11_item_type_idx ON public.versions_y2023_m11 USING btree (item_type);


--
-- Name: versions_y2023_m12_event_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX versions_y2023_m12_event_idx ON public.versions_y2023_m12 USING btree (event);


--
-- Name: versions_y2023_m12_item_type_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX versions_y2023_m12_item_type_idx ON public.versions_y2023_m12 USING btree (item_type);


--
-- Name: versions_y2024_m01_event_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX versions_y2024_m01_event_idx ON public.versions_y2024_m01 USING btree (event);


--
-- Name: versions_y2024_m01_item_type_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX versions_y2024_m01_item_type_idx ON public.versions_y2024_m01 USING btree (item_type);


--
-- Name: versions_y2024_m02_event_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX versions_y2024_m02_event_idx ON public.versions_y2024_m02 USING btree (event);


--
-- Name: versions_y2024_m02_item_type_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX versions_y2024_m02_item_type_idx ON public.versions_y2024_m02 USING btree (item_type);


--
-- Name: index_versions_event_177765f; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_versions_event ATTACH PARTITION public.index_versions_event_177765f;


--
-- Name: index_versions_event_1bf0c9a; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_versions_event ATTACH PARTITION public.index_versions_event_1bf0c9a;


--
-- Name: index_versions_event_44d370e; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_versions_event ATTACH PARTITION public.index_versions_event_44d370e;


--
-- Name: index_versions_event_4dc39ba; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_versions_event ATTACH PARTITION public.index_versions_event_4dc39ba;


--
-- Name: index_versions_event_5d3b480; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_versions_event ATTACH PARTITION public.index_versions_event_5d3b480;


--
-- Name: index_versions_event_716484f; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_versions_event ATTACH PARTITION public.index_versions_event_716484f;


--
-- Name: index_versions_event_b414805; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_versions_event ATTACH PARTITION public.index_versions_event_b414805;


--
-- Name: index_versions_event_e4a326e; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_versions_event ATTACH PARTITION public.index_versions_event_e4a326e;


--
-- Name: index_versions_item_type_177765f; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_versions_item_type ATTACH PARTITION public.index_versions_item_type_177765f;


--
-- Name: index_versions_item_type_1bf0c9a; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_versions_item_type ATTACH PARTITION public.index_versions_item_type_1bf0c9a;


--
-- Name: index_versions_item_type_44d370e; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_versions_item_type ATTACH PARTITION public.index_versions_item_type_44d370e;


--
-- Name: index_versions_item_type_4dc39ba; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_versions_item_type ATTACH PARTITION public.index_versions_item_type_4dc39ba;


--
-- Name: index_versions_item_type_5d3b480; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_versions_item_type ATTACH PARTITION public.index_versions_item_type_5d3b480;


--
-- Name: index_versions_item_type_716484f; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_versions_item_type ATTACH PARTITION public.index_versions_item_type_716484f;


--
-- Name: index_versions_item_type_b414805; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_versions_item_type ATTACH PARTITION public.index_versions_item_type_b414805;


--
-- Name: index_versions_item_type_e4a326e; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_versions_item_type ATTACH PARTITION public.index_versions_item_type_e4a326e;


--
-- Name: versions_y2023_m09_event_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_versions_event ATTACH PARTITION public.versions_y2023_m09_event_idx;


--
-- Name: versions_y2023_m09_item_type_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_versions_item_type ATTACH PARTITION public.versions_y2023_m09_item_type_idx;


--
-- Name: versions_y2023_m10_event_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_versions_event ATTACH PARTITION public.versions_y2023_m10_event_idx;


--
-- Name: versions_y2023_m10_item_type_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_versions_item_type ATTACH PARTITION public.versions_y2023_m10_item_type_idx;


--
-- Name: versions_y2023_m11_event_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_versions_event ATTACH PARTITION public.versions_y2023_m11_event_idx;


--
-- Name: versions_y2023_m11_item_type_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_versions_item_type ATTACH PARTITION public.versions_y2023_m11_item_type_idx;


--
-- Name: versions_y2023_m12_event_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_versions_event ATTACH PARTITION public.versions_y2023_m12_event_idx;


--
-- Name: versions_y2023_m12_item_type_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_versions_item_type ATTACH PARTITION public.versions_y2023_m12_item_type_idx;


--
-- Name: versions_y2024_m01_event_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_versions_event ATTACH PARTITION public.versions_y2024_m01_event_idx;


--
-- Name: versions_y2024_m01_item_type_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_versions_item_type ATTACH PARTITION public.versions_y2024_m01_item_type_idx;


--
-- Name: versions_y2024_m02_event_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_versions_event ATTACH PARTITION public.versions_y2024_m02_event_idx;


--
-- Name: versions_y2024_m02_item_type_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.index_versions_item_type ATTACH PARTITION public.versions_y2024_m02_item_type_idx;


--
-- Name: roles fk_rails_02e163ac0c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT fk_rails_02e163ac0c FOREIGN KEY (group_id) REFERENCES public.groups(id) ON DELETE SET NULL;


--
-- Name: dependencies fk_rails_0dc77e38f3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dependencies
    ADD CONSTRAINT fk_rails_0dc77e38f3 FOREIGN KEY (successor_id) REFERENCES public.actions(id) ON DELETE SET NULL;


--
-- Name: imports fk_rails_138d41de18; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.imports
    ADD CONSTRAINT fk_rails_138d41de18 FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE SET NULL;


--
-- Name: projects_suppliers fk_rails_199e3266a5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects_suppliers
    ADD CONSTRAINT fk_rails_199e3266a5 FOREIGN KEY (supplier_id) REFERENCES public.clients(id) ON DELETE CASCADE;


--
-- Name: scheduled_scans fk_rails_221c135009; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scheduled_scans
    ADD CONSTRAINT fk_rails_221c135009 FOREIGN KEY (scan_configuration_id) REFERENCES public.scan_configurations(id) ON DELETE CASCADE;


--
-- Name: exploits_vulnerabilities fk_rails_24573cf71a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exploits_vulnerabilities
    ADD CONSTRAINT fk_rails_24573cf71a FOREIGN KEY (vulnerability_id) REFERENCES public.vulnerabilities(id) ON DELETE CASCADE;


--
-- Name: comments fk_rails_2461ca4182; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT fk_rails_2461ca4182 FOREIGN KEY (action_id) REFERENCES public.actions(id) ON DELETE CASCADE;


--
-- Name: reports_targets fk_rails_28026b9ca0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports_targets
    ADD CONSTRAINT fk_rails_28026b9ca0 FOREIGN KEY (reports_vm_scans_id) REFERENCES public.reports_vm_scans(id) ON DELETE CASCADE;


--
-- Name: wa_occurrences fk_rails_2ebacf71a3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wa_occurrences
    ADD CONSTRAINT fk_rails_2ebacf71a3 FOREIGN KEY (vulnerability_id) REFERENCES public.vulnerabilities(id) ON DELETE CASCADE;


--
-- Name: reports_wa_scans fk_rails_34261f61d6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports_wa_scans
    ADD CONSTRAINT fk_rails_34261f61d6 FOREIGN KEY (wa_scan_id) REFERENCES public.wa_scans(id) ON DELETE CASCADE;


--
-- Name: report_exports fk_rails_3b7c5a0fba; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_exports
    ADD CONSTRAINT fk_rails_3b7c5a0fba FOREIGN KEY (report_id) REFERENCES public.reports(id) ON DELETE CASCADE;


--
-- Name: dependencies fk_rails_3c24b3ae8b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dependencies
    ADD CONSTRAINT fk_rails_3c24b3ae8b FOREIGN KEY (predecessor_id) REFERENCES public.actions(id) ON DELETE SET NULL;


--
-- Name: staffs_teams fk_rails_3f7ee31588; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staffs_teams
    ADD CONSTRAINT fk_rails_3f7ee31588 FOREIGN KEY (team_id) REFERENCES public.teams(id) ON DELETE CASCADE;


--
-- Name: users_roles fk_rails_4a41696df6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_roles
    ADD CONSTRAINT fk_rails_4a41696df6 FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: projects_suppliers fk_rails_4c587149af; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects_suppliers
    ADD CONSTRAINT fk_rails_4c587149af FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: users_groups fk_rails_4fd01181dc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_groups
    ADD CONSTRAINT fk_rails_4fd01181dc FOREIGN KEY (group_id) REFERENCES public.groups(id) ON DELETE CASCADE;


--
-- Name: reports_vm_scans fk_rails_536287a901; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports_vm_scans
    ADD CONSTRAINT fk_rails_536287a901 FOREIGN KEY (vm_scan_id) REFERENCES public.vm_scans(id) ON DELETE CASCADE;


--
-- Name: accounts_suppliers fk_rails_566e2af1bc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts_suppliers
    ADD CONSTRAINT fk_rails_566e2af1bc FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: vm_occurrences fk_rails_5801f376fb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vm_occurrences
    ADD CONSTRAINT fk_rails_5801f376fb FOREIGN KEY (scan_id) REFERENCES public.vm_scans(id) ON DELETE SET NULL;


--
-- Name: reports_contacts fk_rails_60c1fb3f68; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports_contacts
    ADD CONSTRAINT fk_rails_60c1fb3f68 FOREIGN KEY (contact_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: imports fk_rails_63f4a42a16; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.imports
    ADD CONSTRAINT fk_rails_63f4a42a16 FOREIGN KEY (scan_launch_id) REFERENCES public.scan_launches(id) ON DELETE SET NULL;


--
-- Name: clients_contacts fk_rails_6fb077f975; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clients_contacts
    ADD CONSTRAINT fk_rails_6fb077f975 FOREIGN KEY (contact_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: wa_occurrences fk_rails_7308751313; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wa_occurrences
    ADD CONSTRAINT fk_rails_7308751313 FOREIGN KEY (scan_id) REFERENCES public.wa_scans(id) ON DELETE SET NULL;


--
-- Name: aggregates_wa_occurrences fk_rails_73867f9a41; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aggregates_wa_occurrences
    ADD CONSTRAINT fk_rails_73867f9a41 FOREIGN KEY (wa_occurrence_id) REFERENCES public.wa_occurrences(id) ON DELETE CASCADE;


--
-- Name: staffs_teams fk_rails_74b3102ef6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staffs_teams
    ADD CONSTRAINT fk_rails_74b3102ef6 FOREIGN KEY (staff_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: reports fk_rails_769ec997a3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT fk_rails_769ec997a3 FOREIGN KEY (staff_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: report_exports fk_rails_78f6bd9216; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_exports
    ADD CONSTRAINT fk_rails_78f6bd9216 FOREIGN KEY (exporter_id) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: exploits fk_rails_7a2f552faf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exploits
    ADD CONSTRAINT fk_rails_7a2f552faf FOREIGN KEY (exploit_source_id) REFERENCES public.exploit_sources(id) ON DELETE CASCADE;


--
-- Name: reports_contacts fk_rails_8369b1c933; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports_contacts
    ADD CONSTRAINT fk_rails_8369b1c933 FOREIGN KEY (report_id) REFERENCES public.reports(id) ON DELETE CASCADE;


--
-- Name: aggregates_vm_occurrences fk_rails_84611ce967; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aggregates_vm_occurrences
    ADD CONSTRAINT fk_rails_84611ce967 FOREIGN KEY (aggregate_id) REFERENCES public.aggregates(id) ON DELETE CASCADE;


--
-- Name: projects fk_rails_8d9657cec3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT fk_rails_8d9657cec3 FOREIGN KEY (client_id) REFERENCES public.clients(id) ON DELETE CASCADE;


--
-- Name: certificates_languages fk_rails_90a15838f7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certificates_languages
    ADD CONSTRAINT fk_rails_90a15838f7 FOREIGN KEY (language_id) REFERENCES public.languages(id) ON DELETE CASCADE;


--
-- Name: vm_occurrences fk_rails_96cca41817; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vm_occurrences
    ADD CONSTRAINT fk_rails_96cca41817 FOREIGN KEY (vulnerability_id) REFERENCES public.vulnerabilities(id) ON DELETE CASCADE;


--
-- Name: active_storage_variant_records fk_rails_993965df05; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT fk_rails_993965df05 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: reports fk_rails_9a0a9c9bec; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT fk_rails_9a0a9c9bec FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE SET NULL;


--
-- Name: scan_launches fk_rails_9af7fb30d9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scan_launches
    ADD CONSTRAINT fk_rails_9af7fb30d9 FOREIGN KEY (scan_configuration_id) REFERENCES public.scan_configurations(id) ON DELETE SET NULL;


--
-- Name: certificates fk_rails_9f7dd9de0c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certificates
    ADD CONSTRAINT fk_rails_9f7dd9de0c FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE SET NULL;


--
-- Name: reports fk_rails_a0bb6ea168; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT fk_rails_a0bb6ea168 FOREIGN KEY (signatory_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: statistics fk_rails_ae121503c1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.statistics
    ADD CONSTRAINT fk_rails_ae121503c1 FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE SET NULL;


--
-- Name: certificates_languages fk_rails_afc3369aeb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certificates_languages
    ADD CONSTRAINT fk_rails_afc3369aeb FOREIGN KEY (certificate_id) REFERENCES public.certificates(id) ON DELETE CASCADE;


--
-- Name: users_groups fk_rails_afe1a63b61; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_groups
    ADD CONSTRAINT fk_rails_afe1a63b61 FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: aggregates fk_rails_b676ee2085; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aggregates
    ADD CONSTRAINT fk_rails_b676ee2085 FOREIGN KEY (report_id) REFERENCES public.reports(id) ON DELETE SET NULL;


--
-- Name: scan_launches fk_rails_b78a528f0e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scan_launches
    ADD CONSTRAINT fk_rails_b78a528f0e FOREIGN KEY (csis_job_id) REFERENCES public.jobs(id) ON DELETE SET NULL;


--
-- Name: reports_vm_scans fk_rails_b9b598eb17; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports_vm_scans
    ADD CONSTRAINT fk_rails_b9b598eb17 FOREIGN KEY (report_id) REFERENCES public.reports(id) ON DELETE CASCADE;


--
-- Name: aggregates_vm_occurrences fk_rails_bd2fffec58; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aggregates_vm_occurrences
    ADD CONSTRAINT fk_rails_bd2fffec58 FOREIGN KEY (vm_occurrence_id) REFERENCES public.vm_occurrences(id) ON DELETE CASCADE;


--
-- Name: accounts_suppliers fk_rails_beee89de77; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts_suppliers
    ADD CONSTRAINT fk_rails_beee89de77 FOREIGN KEY (supplier_id) REFERENCES public.clients(id) ON DELETE CASCADE;


--
-- Name: active_storage_attachments fk_rails_c3b3935057; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT fk_rails_c3b3935057 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: exploits_vulnerabilities fk_rails_c606c89e54; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exploits_vulnerabilities
    ADD CONSTRAINT fk_rails_c606c89e54 FOREIGN KEY (exploit_id) REFERENCES public.exploits(id) ON DELETE CASCADE;


--
-- Name: aggregates fk_rails_c62bc5868a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aggregates
    ADD CONSTRAINT fk_rails_c62bc5868a FOREIGN KEY (from_aggregate_id) REFERENCES public.aggregates(id) ON DELETE SET NULL;


--
-- Name: reports_targets fk_rails_c6d77bf866; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports_targets
    ADD CONSTRAINT fk_rails_c6d77bf866 FOREIGN KEY (target_id) REFERENCES public.targets(id) ON DELETE CASCADE;


--
-- Name: reports_wa_scans fk_rails_c87b30b1d8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports_wa_scans
    ADD CONSTRAINT fk_rails_c87b30b1d8 FOREIGN KEY (report_id) REFERENCES public.reports(id) ON DELETE CASCADE;


--
-- Name: clients_contacts fk_rails_db037821eb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clients_contacts
    ADD CONSTRAINT fk_rails_db037821eb FOREIGN KEY (client_id) REFERENCES public.clients(id) ON DELETE CASCADE;


--
-- Name: accounts fk_rails_dbf2f0c3ae; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT fk_rails_dbf2f0c3ae FOREIGN KEY (external_application_id) REFERENCES public.external_applications(id) ON DELETE SET NULL;


--
-- Name: users_roles fk_rails_eb7b4658f8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users_roles
    ADD CONSTRAINT fk_rails_eb7b4658f8 FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE;


--
-- Name: aggregates_wa_occurrences fk_rails_efca1f376b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aggregates_wa_occurrences
    ADD CONSTRAINT fk_rails_efca1f376b FOREIGN KEY (aggregate_id) REFERENCES public.aggregates(id) ON DELETE CASCADE;


--
-- Name: clients_suppliers fk_rails_f2a4d0f2ab; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clients_suppliers
    ADD CONSTRAINT fk_rails_f2a4d0f2ab FOREIGN KEY (supplier_id) REFERENCES public.clients(id) ON DELETE CASCADE;


--
-- Name: clients_suppliers fk_rails_f87e767a38; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clients_suppliers
    ADD CONSTRAINT fk_rails_f87e767a38 FOREIGN KEY (client_id) REFERENCES public.clients(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20180319101435'),
('20180405082932'),
('20180405144437'),
('20180410130437'),
('20180410130515'),
('20180413120508'),
('20180416080432'),
('20180416081849'),
('20180417082921'),
('20180418091700'),
('20180418091705'),
('20180418092758'),
('20180419123524'),
('20180424092049'),
('20180424132949'),
('20180424143627'),
('20180424150636'),
('20180425074002'),
('20180425074338'),
('20180425074456'),
('20180425154740'),
('20180426080214'),
('20180426091414'),
('20180430132009'),
('20180430132131'),
('20180507080422'),
('20180507082555'),
('20180507085321'),
('20180507090919'),
('20180507094523'),
('20180507094528'),
('20180509091924'),
('20180509092933'),
('20180509124935'),
('20180509133324'),
('20180509140520'),
('20180514134629'),
('20180515124140'),
('20180515150335'),
('20180516141432'),
('20180518084323'),
('20180523134459'),
('20180525100512'),
('20180529141417'),
('20180531092832'),
('20180614090302'),
('20180628122152'),
('20180628124713'),
('20180703085342'),
('20180720133623'),
('20180803004147'),
('20180803073708'),
('20180803083018'),
('20180803083154'),
('20180803134724'),
('20180828130126'),
('20180829183443'),
('20181203130605'),
('20181203155735'),
('20181213055848'),
('20190103172654'),
('20190227082921'),
('20190227082928'),
('20190303172654'),
('20190303172859'),
('20190331134751'),
('20190401071339'),
('20190401083815'),
('20190401094032'),
('20190403120036'),
('20190403150240'),
('20190411150335'),
('20190411160335'),
('20190411160835'),
('20190423140538'),
('20190425085113'),
('20190426130419'),
('20190430083905'),
('20190510113519'),
('20190516124225'),
('20190612102639'),
('20190618150423'),
('20190624081804'),
('20190628145759'),
('20190710124135'),
('20190711081159'),
('20190715133025'),
('20190722094634'),
('20190723101616'),
('20190726071154'),
('20190726115012'),
('20190806140614'),
('20190806155920'),
('20190807103748'),
('20190821160545'),
('20190830160637'),
('20190830163406'),
('20190911091845'),
('20190913101911'),
('20191001083930'),
('20191003100724'),
('20191008130327'),
('20191018133048'),
('20191018140639'),
('20191107103437'),
('20191202141006'),
('20191216100348'),
('20200218141601'),
('20200221140034'),
('20200224095637'),
('20200225171548'),
('20200227152158'),
('20200302163238'),
('20200305130346'),
('20200306185317'),
('20200309142602'),
('20200309151924'),
('20200311144410'),
('20200312162832'),
('20200321151027'),
('20200322141516'),
('20200323093936'),
('20200406141227'),
('20200418141526'),
('20200427084644'),
('20200512095939'),
('20200525154006'),
('20200821074443'),
('20200826141151'),
('20200917174605'),
('20201005141718'),
('20201005144857'),
('20201008081049'),
('20201009120457'),
('20201012113120'),
('20201102132004'),
('20201109093440'),
('20201113094405'),
('20201124110805'),
('20201214132731'),
('20201221091643'),
('20210105144006'),
('20210105144007'),
('20210205090423'),
('20210210081541'),
('20210217144659'),
('20210223085356'),
('20210225111943'),
('20210301134330'),
('20210309095152'),
('20210325160515'),
('20210402141619'),
('20210406154138'),
('20210407092454'),
('20210409164838'),
('20210430084407'),
('20210505124454'),
('20210507160003'),
('20210514131650'),
('20210517135804'),
('20210521134329'),
('20210604131321'),
('20210715074243'),
('20220122150832'),
('20220203000000'),
('20220205000000'),
('20220228162506'),
('20220315143717'),
('20220525093325'),
('20220608134305'),
('20220610134017'),
('20220621150330'),
('20220817103453'),
('20221003172121'),
('20230109182110'),
('20230320155636'),
('20230622081822'),
('20231128155539'),
('20231130133054'),
('20231219141717'),
('20231220091213'),
('20240118091552');


