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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: bookmarks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookmarks (
    id integer NOT NULL,
    user_id integer NOT NULL,
    user_type character varying,
    document_id character varying,
    document_type character varying,
    title bytea,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: bookmarks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookmarks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookmarks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookmarks_id_seq OWNED BY public.bookmarks.id;


--
-- Name: checksum_audit_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.checksum_audit_logs (
    id bigint NOT NULL,
    file_set_id character varying,
    file_id character varying,
    checked_uri character varying,
    expected_result character varying,
    actual_result character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    passed boolean
);


--
-- Name: checksum_audit_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.checksum_audit_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: checksum_audit_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.checksum_audit_logs_id_seq OWNED BY public.checksum_audit_logs.id;


--
-- Name: collection_branding_infos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collection_branding_infos (
    id bigint NOT NULL,
    collection_id character varying,
    role character varying,
    local_path character varying,
    alt_text character varying,
    target_url character varying,
    height integer,
    width integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: collection_branding_infos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.collection_branding_infos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: collection_branding_infos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.collection_branding_infos_id_seq OWNED BY public.collection_branding_infos.id;


--
-- Name: collection_type_participants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collection_type_participants (
    id bigint NOT NULL,
    hyrax_collection_type_id bigint,
    agent_type character varying,
    agent_id character varying,
    access character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: collection_type_participants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.collection_type_participants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: collection_type_participants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.collection_type_participants_id_seq OWNED BY public.collection_type_participants.id;


--
-- Name: content_blocks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content_blocks (
    id bigint NOT NULL,
    name character varying,
    value text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    external_key character varying
);


--
-- Name: content_blocks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.content_blocks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: content_blocks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.content_blocks_id_seq OWNED BY public.content_blocks.id;


--
-- Name: curation_concerns_operations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.curation_concerns_operations (
    id bigint NOT NULL,
    status character varying,
    operation_type character varying,
    job_class character varying,
    job_id character varying,
    type character varying,
    message text,
    user_id bigint,
    parent_id integer,
    lft integer NOT NULL,
    rgt integer NOT NULL,
    depth integer DEFAULT 0 NOT NULL,
    children_count integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: curation_concerns_operations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.curation_concerns_operations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: curation_concerns_operations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.curation_concerns_operations_id_seq OWNED BY public.curation_concerns_operations.id;


--
-- Name: featured_collections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.featured_collections (
    id bigint NOT NULL,
    "order" integer DEFAULT 4,
    collection_id character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: featured_collections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.featured_collections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: featured_collections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.featured_collections_id_seq OWNED BY public.featured_collections.id;


--
-- Name: featured_works; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.featured_works (
    id bigint NOT NULL,
    "order" integer DEFAULT 5,
    work_id character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: featured_works_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.featured_works_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: featured_works_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.featured_works_id_seq OWNED BY public.featured_works.id;


--
-- Name: file_download_stats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_download_stats (
    id bigint NOT NULL,
    date timestamp without time zone,
    downloads integer,
    file_id character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id integer
);


--
-- Name: file_download_stats_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.file_download_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_download_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.file_download_stats_id_seq OWNED BY public.file_download_stats.id;


--
-- Name: file_view_stats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_view_stats (
    id bigint NOT NULL,
    date timestamp without time zone,
    views integer,
    file_id character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id integer
);


--
-- Name: file_view_stats_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.file_view_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_view_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.file_view_stats_id_seq OWNED BY public.file_view_stats.id;


--
-- Name: hyrax_collection_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hyrax_collection_types (
    id bigint NOT NULL,
    title character varying,
    description text,
    machine_id character varying,
    nestable boolean DEFAULT true NOT NULL,
    discoverable boolean DEFAULT true NOT NULL,
    sharable boolean DEFAULT true NOT NULL,
    allow_multiple_membership boolean DEFAULT true NOT NULL,
    require_membership boolean DEFAULT false NOT NULL,
    assigns_workflow boolean DEFAULT false NOT NULL,
    assigns_visibility boolean DEFAULT false NOT NULL,
    share_applies_to_new_works boolean DEFAULT true NOT NULL,
    brandable boolean DEFAULT true NOT NULL,
    badge_color character varying DEFAULT '#663333'::character varying
);


--
-- Name: hyrax_collection_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.hyrax_collection_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: hyrax_collection_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.hyrax_collection_types_id_seq OWNED BY public.hyrax_collection_types.id;


--
-- Name: hyrax_features; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hyrax_features (
    id bigint NOT NULL,
    key character varying NOT NULL,
    enabled boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: hyrax_features_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.hyrax_features_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: hyrax_features_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.hyrax_features_id_seq OWNED BY public.hyrax_features.id;


--
-- Name: job_io_wrappers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.job_io_wrappers (
    id bigint NOT NULL,
    user_id bigint,
    uploaded_file_id bigint,
    file_set_id character varying,
    mime_type character varying,
    original_name character varying,
    path character varying,
    relation character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: job_io_wrappers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.job_io_wrappers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_io_wrappers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.job_io_wrappers_id_seq OWNED BY public.job_io_wrappers.id;


--
-- Name: mailboxer_conversation_opt_outs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mailboxer_conversation_opt_outs (
    id integer NOT NULL,
    unsubscriber_type character varying,
    unsubscriber_id integer,
    conversation_id integer
);


--
-- Name: mailboxer_conversation_opt_outs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mailboxer_conversation_opt_outs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mailboxer_conversation_opt_outs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mailboxer_conversation_opt_outs_id_seq OWNED BY public.mailboxer_conversation_opt_outs.id;


--
-- Name: mailboxer_conversations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mailboxer_conversations (
    id integer NOT NULL,
    subject character varying DEFAULT ''::character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: mailboxer_conversations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mailboxer_conversations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mailboxer_conversations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mailboxer_conversations_id_seq OWNED BY public.mailboxer_conversations.id;


--
-- Name: mailboxer_notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mailboxer_notifications (
    id integer NOT NULL,
    type character varying,
    body text,
    subject character varying DEFAULT ''::character varying,
    sender_type character varying,
    sender_id integer,
    conversation_id integer,
    draft boolean DEFAULT false,
    notification_code character varying,
    notified_object_type character varying,
    notified_object_id integer,
    attachment character varying,
    updated_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    global boolean DEFAULT false,
    expires timestamp without time zone
);


--
-- Name: mailboxer_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mailboxer_notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mailboxer_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mailboxer_notifications_id_seq OWNED BY public.mailboxer_notifications.id;


--
-- Name: mailboxer_receipts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mailboxer_receipts (
    id integer NOT NULL,
    receiver_type character varying,
    receiver_id integer,
    notification_id integer NOT NULL,
    is_read boolean DEFAULT false,
    trashed boolean DEFAULT false,
    deleted boolean DEFAULT false,
    mailbox_type character varying(25),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_delivered boolean DEFAULT false,
    delivery_method character varying,
    message_id character varying
);


--
-- Name: mailboxer_receipts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mailboxer_receipts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mailboxer_receipts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mailboxer_receipts_id_seq OWNED BY public.mailboxer_receipts.id;


--
-- Name: minter_states; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.minter_states (
    id integer NOT NULL,
    namespace character varying DEFAULT 'default'::character varying NOT NULL,
    template character varying NOT NULL,
    counters text,
    seq bigint DEFAULT 0,
    rand bytea,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: minter_states_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.minter_states_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: minter_states_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.minter_states_id_seq OWNED BY public.minter_states.id;


--
-- Name: permission_template_accesses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.permission_template_accesses (
    id bigint NOT NULL,
    permission_template_id bigint,
    agent_type character varying,
    agent_id character varying,
    access character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: permission_template_accesses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.permission_template_accesses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: permission_template_accesses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.permission_template_accesses_id_seq OWNED BY public.permission_template_accesses.id;


--
-- Name: permission_templates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.permission_templates (
    id bigint NOT NULL,
    source_id character varying,
    visibility character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    release_date date,
    release_period character varying
);


--
-- Name: permission_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.permission_templates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: permission_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.permission_templates_id_seq OWNED BY public.permission_templates.id;


--
-- Name: proxy_deposit_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.proxy_deposit_requests (
    id bigint NOT NULL,
    work_id character varying NOT NULL,
    sending_user_id bigint NOT NULL,
    receiving_user_id bigint NOT NULL,
    fulfillment_date timestamp without time zone,
    status character varying DEFAULT 'pending'::character varying NOT NULL,
    sender_comment text,
    receiver_comment text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: proxy_deposit_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.proxy_deposit_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: proxy_deposit_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.proxy_deposit_requests_id_seq OWNED BY public.proxy_deposit_requests.id;


--
-- Name: proxy_deposit_rights; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.proxy_deposit_rights (
    id bigint NOT NULL,
    grantor_id bigint,
    grantee_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: proxy_deposit_rights_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.proxy_deposit_rights_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: proxy_deposit_rights_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.proxy_deposit_rights_id_seq OWNED BY public.proxy_deposit_rights.id;


--
-- Name: qa_local_authorities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.qa_local_authorities (
    id bigint NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: qa_local_authorities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.qa_local_authorities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: qa_local_authorities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.qa_local_authorities_id_seq OWNED BY public.qa_local_authorities.id;


--
-- Name: qa_local_authority_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.qa_local_authority_entries (
    id bigint NOT NULL,
    local_authority_id bigint,
    label character varying,
    uri character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: qa_local_authority_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.qa_local_authority_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: qa_local_authority_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.qa_local_authority_entries_id_seq OWNED BY public.qa_local_authority_entries.id;


--
-- Name: rdf_labels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rdf_labels (
    id bigint NOT NULL,
    uri character varying NOT NULL,
    value character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: rdf_labels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rdf_labels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rdf_labels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rdf_labels_id_seq OWNED BY public.rdf_labels.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    name character varying
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: roles_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles_users (
    role_id integer,
    user_id integer
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: searches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.searches (
    id integer NOT NULL,
    query_params bytea,
    user_id integer,
    user_type character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: searches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.searches_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: searches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.searches_id_seq OWNED BY public.searches.id;


--
-- Name: single_use_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.single_use_links (
    id bigint NOT NULL,
    "downloadKey" character varying,
    path character varying,
    "itemId" character varying,
    expires timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: single_use_links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.single_use_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: single_use_links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.single_use_links_id_seq OWNED BY public.single_use_links.id;


--
-- Name: sipity_agents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sipity_agents (
    id bigint NOT NULL,
    proxy_for_id character varying NOT NULL,
    proxy_for_type character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sipity_agents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sipity_agents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sipity_agents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sipity_agents_id_seq OWNED BY public.sipity_agents.id;


--
-- Name: sipity_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sipity_comments (
    id bigint NOT NULL,
    entity_id integer NOT NULL,
    agent_id integer NOT NULL,
    comment text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sipity_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sipity_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sipity_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sipity_comments_id_seq OWNED BY public.sipity_comments.id;


--
-- Name: sipity_entities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sipity_entities (
    id bigint NOT NULL,
    proxy_for_global_id character varying NOT NULL,
    workflow_id integer NOT NULL,
    workflow_state_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sipity_entities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sipity_entities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sipity_entities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sipity_entities_id_seq OWNED BY public.sipity_entities.id;


--
-- Name: sipity_entity_specific_responsibilities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sipity_entity_specific_responsibilities (
    id bigint NOT NULL,
    workflow_role_id integer NOT NULL,
    entity_id character varying NOT NULL,
    agent_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sipity_entity_specific_responsibilities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sipity_entity_specific_responsibilities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sipity_entity_specific_responsibilities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sipity_entity_specific_responsibilities_id_seq OWNED BY public.sipity_entity_specific_responsibilities.id;


--
-- Name: sipity_notifiable_contexts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sipity_notifiable_contexts (
    id bigint NOT NULL,
    scope_for_notification_id integer NOT NULL,
    scope_for_notification_type character varying NOT NULL,
    reason_for_notification character varying NOT NULL,
    notification_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sipity_notifiable_contexts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sipity_notifiable_contexts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sipity_notifiable_contexts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sipity_notifiable_contexts_id_seq OWNED BY public.sipity_notifiable_contexts.id;


--
-- Name: sipity_notification_recipients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sipity_notification_recipients (
    id bigint NOT NULL,
    notification_id integer NOT NULL,
    role_id integer NOT NULL,
    recipient_strategy character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sipity_notification_recipients_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sipity_notification_recipients_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sipity_notification_recipients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sipity_notification_recipients_id_seq OWNED BY public.sipity_notification_recipients.id;


--
-- Name: sipity_notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sipity_notifications (
    id bigint NOT NULL,
    name character varying NOT NULL,
    notification_type character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sipity_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sipity_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sipity_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sipity_notifications_id_seq OWNED BY public.sipity_notifications.id;


--
-- Name: sipity_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sipity_roles (
    id bigint NOT NULL,
    name character varying NOT NULL,
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sipity_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sipity_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sipity_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sipity_roles_id_seq OWNED BY public.sipity_roles.id;


--
-- Name: sipity_workflow_actions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sipity_workflow_actions (
    id bigint NOT NULL,
    workflow_id integer NOT NULL,
    resulting_workflow_state_id integer,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sipity_workflow_actions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sipity_workflow_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sipity_workflow_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sipity_workflow_actions_id_seq OWNED BY public.sipity_workflow_actions.id;


--
-- Name: sipity_workflow_methods; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sipity_workflow_methods (
    id bigint NOT NULL,
    service_name character varying NOT NULL,
    weight integer NOT NULL,
    workflow_action_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sipity_workflow_methods_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sipity_workflow_methods_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sipity_workflow_methods_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sipity_workflow_methods_id_seq OWNED BY public.sipity_workflow_methods.id;


--
-- Name: sipity_workflow_responsibilities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sipity_workflow_responsibilities (
    id bigint NOT NULL,
    agent_id integer NOT NULL,
    workflow_role_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sipity_workflow_responsibilities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sipity_workflow_responsibilities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sipity_workflow_responsibilities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sipity_workflow_responsibilities_id_seq OWNED BY public.sipity_workflow_responsibilities.id;


--
-- Name: sipity_workflow_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sipity_workflow_roles (
    id bigint NOT NULL,
    workflow_id integer NOT NULL,
    role_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sipity_workflow_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sipity_workflow_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sipity_workflow_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sipity_workflow_roles_id_seq OWNED BY public.sipity_workflow_roles.id;


--
-- Name: sipity_workflow_state_action_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sipity_workflow_state_action_permissions (
    id bigint NOT NULL,
    workflow_role_id integer NOT NULL,
    workflow_state_action_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sipity_workflow_state_action_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sipity_workflow_state_action_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sipity_workflow_state_action_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sipity_workflow_state_action_permissions_id_seq OWNED BY public.sipity_workflow_state_action_permissions.id;


--
-- Name: sipity_workflow_state_actions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sipity_workflow_state_actions (
    id bigint NOT NULL,
    originating_workflow_state_id integer NOT NULL,
    workflow_action_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sipity_workflow_state_actions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sipity_workflow_state_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sipity_workflow_state_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sipity_workflow_state_actions_id_seq OWNED BY public.sipity_workflow_state_actions.id;


--
-- Name: sipity_workflow_states; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sipity_workflow_states (
    id bigint NOT NULL,
    workflow_id integer NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sipity_workflow_states_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sipity_workflow_states_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sipity_workflow_states_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sipity_workflow_states_id_seq OWNED BY public.sipity_workflow_states.id;


--
-- Name: sipity_workflows; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sipity_workflows (
    id bigint NOT NULL,
    name character varying NOT NULL,
    label character varying,
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    permission_template_id integer,
    active boolean,
    allows_access_grant boolean
);


--
-- Name: sipity_workflows_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sipity_workflows_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sipity_workflows_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sipity_workflows_id_seq OWNED BY public.sipity_workflows.id;


--
-- Name: tinymce_assets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tinymce_assets (
    id bigint NOT NULL,
    file character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: tinymce_assets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tinymce_assets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tinymce_assets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tinymce_assets_id_seq OWNED BY public.tinymce_assets.id;


--
-- Name: trophies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trophies (
    id bigint NOT NULL,
    user_id integer,
    work_id character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: trophies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.trophies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trophies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.trophies_id_seq OWNED BY public.trophies.id;


--
-- Name: uploaded_files; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.uploaded_files (
    id bigint NOT NULL,
    file character varying,
    user_id bigint,
    file_set_uri character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: uploaded_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.uploaded_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: uploaded_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.uploaded_files_id_seq OWNED BY public.uploaded_files.id;


--
-- Name: user_stats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_stats (
    id bigint NOT NULL,
    user_id integer,
    date timestamp without time zone,
    file_views integer,
    file_downloads integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    work_views integer
);


--
-- Name: user_stats_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_stats_id_seq OWNED BY public.user_stats.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    guest boolean DEFAULT false,
    facebook_handle character varying,
    twitter_handle character varying,
    googleplus_handle character varying,
    display_name character varying,
    address character varying,
    admin_area character varying,
    department character varying,
    title character varying,
    office character varying,
    chat_id character varying,
    website character varying,
    affiliation character varying,
    telephone character varying,
    avatar_file_name character varying,
    avatar_content_type character varying,
    avatar_file_size integer,
    avatar_updated_at timestamp without time zone,
    linkedin_handle character varying,
    orcid character varying,
    arkivo_token character varying,
    arkivo_subscription character varying,
    zotero_token bytea,
    zotero_userid character varying,
    preferred_locale character varying,
    username character varying
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: version_committers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.version_committers (
    id bigint NOT NULL,
    obj_id character varying,
    datastream_id character varying,
    version_id character varying,
    committer_login character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: version_committers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.version_committers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: version_committers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.version_committers_id_seq OWNED BY public.version_committers.id;


--
-- Name: work_view_stats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.work_view_stats (
    id bigint NOT NULL,
    date timestamp without time zone,
    work_views integer,
    work_id character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id integer
);


--
-- Name: work_view_stats_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.work_view_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: work_view_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.work_view_stats_id_seq OWNED BY public.work_view_stats.id;


--
-- Name: bookmarks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookmarks ALTER COLUMN id SET DEFAULT nextval('public.bookmarks_id_seq'::regclass);


--
-- Name: checksum_audit_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checksum_audit_logs ALTER COLUMN id SET DEFAULT nextval('public.checksum_audit_logs_id_seq'::regclass);


--
-- Name: collection_branding_infos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_branding_infos ALTER COLUMN id SET DEFAULT nextval('public.collection_branding_infos_id_seq'::regclass);


--
-- Name: collection_type_participants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_type_participants ALTER COLUMN id SET DEFAULT nextval('public.collection_type_participants_id_seq'::regclass);


--
-- Name: content_blocks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_blocks ALTER COLUMN id SET DEFAULT nextval('public.content_blocks_id_seq'::regclass);


--
-- Name: curation_concerns_operations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.curation_concerns_operations ALTER COLUMN id SET DEFAULT nextval('public.curation_concerns_operations_id_seq'::regclass);


--
-- Name: featured_collections id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.featured_collections ALTER COLUMN id SET DEFAULT nextval('public.featured_collections_id_seq'::regclass);


--
-- Name: featured_works id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.featured_works ALTER COLUMN id SET DEFAULT nextval('public.featured_works_id_seq'::regclass);


--
-- Name: file_download_stats id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_download_stats ALTER COLUMN id SET DEFAULT nextval('public.file_download_stats_id_seq'::regclass);


--
-- Name: file_view_stats id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_view_stats ALTER COLUMN id SET DEFAULT nextval('public.file_view_stats_id_seq'::regclass);


--
-- Name: hyrax_collection_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hyrax_collection_types ALTER COLUMN id SET DEFAULT nextval('public.hyrax_collection_types_id_seq'::regclass);


--
-- Name: hyrax_features id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hyrax_features ALTER COLUMN id SET DEFAULT nextval('public.hyrax_features_id_seq'::regclass);


--
-- Name: job_io_wrappers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_io_wrappers ALTER COLUMN id SET DEFAULT nextval('public.job_io_wrappers_id_seq'::regclass);


--
-- Name: mailboxer_conversation_opt_outs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mailboxer_conversation_opt_outs ALTER COLUMN id SET DEFAULT nextval('public.mailboxer_conversation_opt_outs_id_seq'::regclass);


--
-- Name: mailboxer_conversations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mailboxer_conversations ALTER COLUMN id SET DEFAULT nextval('public.mailboxer_conversations_id_seq'::regclass);


--
-- Name: mailboxer_notifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mailboxer_notifications ALTER COLUMN id SET DEFAULT nextval('public.mailboxer_notifications_id_seq'::regclass);


--
-- Name: mailboxer_receipts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mailboxer_receipts ALTER COLUMN id SET DEFAULT nextval('public.mailboxer_receipts_id_seq'::regclass);


--
-- Name: minter_states id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.minter_states ALTER COLUMN id SET DEFAULT nextval('public.minter_states_id_seq'::regclass);


--
-- Name: permission_template_accesses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permission_template_accesses ALTER COLUMN id SET DEFAULT nextval('public.permission_template_accesses_id_seq'::regclass);


--
-- Name: permission_templates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permission_templates ALTER COLUMN id SET DEFAULT nextval('public.permission_templates_id_seq'::regclass);


--
-- Name: proxy_deposit_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.proxy_deposit_requests ALTER COLUMN id SET DEFAULT nextval('public.proxy_deposit_requests_id_seq'::regclass);


--
-- Name: proxy_deposit_rights id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.proxy_deposit_rights ALTER COLUMN id SET DEFAULT nextval('public.proxy_deposit_rights_id_seq'::regclass);


--
-- Name: qa_local_authorities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.qa_local_authorities ALTER COLUMN id SET DEFAULT nextval('public.qa_local_authorities_id_seq'::regclass);


--
-- Name: qa_local_authority_entries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.qa_local_authority_entries ALTER COLUMN id SET DEFAULT nextval('public.qa_local_authority_entries_id_seq'::regclass);


--
-- Name: rdf_labels id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rdf_labels ALTER COLUMN id SET DEFAULT nextval('public.rdf_labels_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: searches id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.searches ALTER COLUMN id SET DEFAULT nextval('public.searches_id_seq'::regclass);


--
-- Name: single_use_links id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.single_use_links ALTER COLUMN id SET DEFAULT nextval('public.single_use_links_id_seq'::regclass);


--
-- Name: sipity_agents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sipity_agents ALTER COLUMN id SET DEFAULT nextval('public.sipity_agents_id_seq'::regclass);


--
-- Name: sipity_comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sipity_comments ALTER COLUMN id SET DEFAULT nextval('public.sipity_comments_id_seq'::regclass);


--
-- Name: sipity_entities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sipity_entities ALTER COLUMN id SET DEFAULT nextval('public.sipity_entities_id_seq'::regclass);


--
-- Name: sipity_entity_specific_responsibilities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sipity_entity_specific_responsibilities ALTER COLUMN id SET DEFAULT nextval('public.sipity_entity_specific_responsibilities_id_seq'::regclass);


--
-- Name: sipity_notifiable_contexts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sipity_notifiable_contexts ALTER COLUMN id SET DEFAULT nextval('public.sipity_notifiable_contexts_id_seq'::regclass);


--
-- Name: sipity_notification_recipients id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sipity_notification_recipients ALTER COLUMN id SET DEFAULT nextval('public.sipity_notification_recipients_id_seq'::regclass);


--
-- Name: sipity_notifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sipity_notifications ALTER COLUMN id SET DEFAULT nextval('public.sipity_notifications_id_seq'::regclass);


--
-- Name: sipity_roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sipity_roles ALTER COLUMN id SET DEFAULT nextval('public.sipity_roles_id_seq'::regclass);


--
-- Name: sipity_workflow_actions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sipity_workflow_actions ALTER COLUMN id SET DEFAULT nextval('public.sipity_workflow_actions_id_seq'::regclass);


--
-- Name: sipity_workflow_methods id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sipity_workflow_methods ALTER COLUMN id SET DEFAULT nextval('public.sipity_workflow_methods_id_seq'::regclass);


--
-- Name: sipity_workflow_responsibilities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sipity_workflow_responsibilities ALTER COLUMN id SET DEFAULT nextval('public.sipity_workflow_responsibilities_id_seq'::regclass);


--
-- Name: sipity_workflow_roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sipity_workflow_roles ALTER COLUMN id SET DEFAULT nextval('public.sipity_workflow_roles_id_seq'::regclass);


--
-- Name: sipity_workflow_state_action_permissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sipity_workflow_state_action_permissions ALTER COLUMN id SET DEFAULT nextval('public.sipity_workflow_state_action_permissions_id_seq'::regclass);


--
-- Name: sipity_workflow_state_actions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sipity_workflow_state_actions ALTER COLUMN id SET DEFAULT nextval('public.sipity_workflow_state_actions_id_seq'::regclass);


--
-- Name: sipity_workflow_states id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sipity_workflow_states ALTER COLUMN id SET DEFAULT nextval('public.sipity_workflow_states_id_seq'::regclass);


--
-- Name: sipity_workflows id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sipity_workflows ALTER COLUMN id SET DEFAULT nextval('public.sipity_workflows_id_seq'::regclass);


--
-- Name: tinymce_assets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tinymce_assets ALTER COLUMN id SET DEFAULT nextval('public.tinymce_assets_id_seq'::regclass);


--
-- Name: trophies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trophies ALTER COLUMN id SET DEFAULT nextval('public.trophies_id_seq'::regclass);


--
-- Name: uploaded_files id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.uploaded_files ALTER COLUMN id SET DEFAULT nextval('public.uploaded_files_id_seq'::regclass);


--
-- Name: user_stats id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_stats ALTER COLUMN id SET DEFAULT nextval('public.user_stats_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: version_committers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.version_committers ALTER COLUMN id SET DEFAULT nextval('public.version_committers_id_seq'::regclass);


--
-- Name: work_view_stats id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_view_stats ALTER COLUMN id SET DEFAULT nextval('public.work_view_stats_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: bookmarks bookmarks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookmarks
    ADD CONSTRAINT bookmarks_pkey PRIMARY KEY (id);


--
-- Name: checksum_audit_logs checksum_audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.checksum_audit_logs
    ADD CONSTRAINT checksum_audit_logs_pkey PRIMARY KEY (id);


--
-- Name: collection_branding_infos collection_branding_infos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_branding_infos
    ADD CONSTRAINT collection_branding_infos_pkey PRIMARY KEY (id);


--
-- Name: collection_type_participants collection_type_participants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_type_participants
    ADD CONSTRAINT collection_type_participants_pkey PRIMARY KEY (id);


--
-- Name: content_blocks content_blocks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_blocks
    ADD CONSTRAINT content_blocks_pkey PRIMARY KEY (id);


--
-- Name: curation_concerns_operations curation_concerns_operations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.curation_concerns_operations
    ADD CONSTRAINT curation_concerns_operations_pkey PRIMARY KEY (id);


--
-- Name: featured_collections featured_collections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.featured_collections
    ADD CONSTRAINT featured_collections_pkey PRIMARY KEY (id);


--
-- Name: featured_works featured_works_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.featured_works
    ADD CONSTRAINT featured_works_pkey PRIMARY KEY (id);


--
-- Name: file_download_stats file_download_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_download_stats
    ADD CONSTRAINT file_download_stats_pkey PRIMARY KEY (id);


--
-- Name: file_view_stats file_view_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_view_stats
    ADD CONSTRAINT file_view_stats_pkey PRIMARY KEY (id);


--
-- Name: hyrax_collection_types hyrax_collection_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hyrax_collection_types
    ADD CONSTRAINT hyrax_collection_types_pkey PRIMARY KEY (id);


--
-- Name: hyrax_features hyrax_features_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hyrax_features
    ADD CONSTRAINT hyrax_features_pkey PRIMARY KEY (id);


--
-- Name: job_io_wrappers job_io_wrappers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_io_wrappers
    ADD CONSTRAINT job_io_wrappers_pkey PRIMARY KEY (id);


--
-- Name: mailboxer_conversation_opt_outs mailboxer_conversation_opt_outs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mailboxer_conversation_opt_outs
    ADD CONSTRAINT mailboxer_conversation_opt_outs_pkey PRIMARY KEY (id);


--
-- Name: mailboxer_conversations mailboxer_conversations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mailboxer_conversations
    ADD CONSTRAINT mailboxer_conversations_pkey PRIMARY KEY (id);


--
-- Name: mailboxer_notifications mailboxer_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mailboxer_notifications
    ADD CONSTRAINT mailboxer_notifications_pkey PRIMARY KEY (id);


--
-- Name: mailboxer_receipts mailboxer_receipts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mailboxer_receipts
    ADD CONSTRAINT mailboxer_receipts_pkey PRIMARY KEY (id);


--
-- Name: minter_states minter_states_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.minter_states
    ADD CONSTRAINT minter_states_pkey PRIMARY KEY (id);


--
-- Name: permission_template_accesses permission_template_accesses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permission_template_accesses
    ADD CONSTRAINT permission_template_accesses_pkey PRIMARY KEY (id);


--
-- Name: permission_templates permission_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permission_templates
    ADD CONSTRAINT permission_templates_pkey PRIMARY KEY (id);


--
-- Name: proxy_deposit_requests proxy_deposit_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.proxy_deposit_requests
    ADD CONSTRAINT proxy_deposit_requests_pkey PRIMARY KEY (id);


--
-- Name: proxy_deposit_rights proxy_deposit_rights_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.proxy_deposit_rights
    ADD CONSTRAINT proxy_deposit_rights_pkey PRIMARY KEY (id);


--
-- Name: qa_local_authorities qa_local_authorities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.qa_local_authorities
    ADD CONSTRAINT qa_local_authorities_pkey PRIMARY KEY (id);


--
-- Name: qa_local_authority_entries qa_local_authority_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.qa_local_authority_entries
    ADD CONSTRAINT qa_local_authority_entries_pkey PRIMARY KEY (id);


--
-- Name: rdf_labels rdf_labels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rdf_labels
    ADD CONSTRAINT rdf_labels_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: searches searches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.searches
    ADD CONSTRAINT searches_pkey PRIMARY KEY (id);


--
-- Name: single_use_links single_use_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.single_use_links
    ADD CONSTRAINT single_use_links_pkey PRIMARY KEY (id);


--
-- Name: sipity_agents sipity_agents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sipity_agents
    ADD CONSTRAINT sipity_agents_pkey PRIMARY KEY (id);


--
-- Name: sipity_comments sipity_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sipity_comments
    ADD CONSTRAINT sipity_comments_pkey PRIMARY KEY (id);


--
-- Name: sipity_entities sipity_entities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sipity_entities
    ADD CONSTRAINT sipity_entities_pkey PRIMARY KEY (id);


--
-- Name: sipity_entity_specific_responsibilities sipity_entity_specific_responsibilities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sipity_entity_specific_responsibilities
    ADD CONSTRAINT sipity_entity_specific_responsibilities_pkey PRIMARY KEY (id);


--
-- Name: sipity_notifiable_contexts sipity_notifiable_contexts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sipity_notifiable_contexts
    ADD CONSTRAINT sipity_notifiable_contexts_pkey PRIMARY KEY (id);


--
-- Name: sipity_notification_recipients sipity_notification_recipients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sipity_notification_recipients
    ADD CONSTRAINT sipity_notification_recipients_pkey PRIMARY KEY (id);


--
-- Name: sipity_notifications sipity_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sipity_notifications
    ADD CONSTRAINT sipity_notifications_pkey PRIMARY KEY (id);


--
-- Name: sipity_roles sipity_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sipity_roles
    ADD CONSTRAINT sipity_roles_pkey PRIMARY KEY (id);


--
-- Name: sipity_workflow_actions sipity_workflow_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sipity_workflow_actions
    ADD CONSTRAINT sipity_workflow_actions_pkey PRIMARY KEY (id);


--
-- Name: sipity_workflow_methods sipity_workflow_methods_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sipity_workflow_methods
    ADD CONSTRAINT sipity_workflow_methods_pkey PRIMARY KEY (id);


--
-- Name: sipity_workflow_responsibilities sipity_workflow_responsibilities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sipity_workflow_responsibilities
    ADD CONSTRAINT sipity_workflow_responsibilities_pkey PRIMARY KEY (id);


--
-- Name: sipity_workflow_roles sipity_workflow_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sipity_workflow_roles
    ADD CONSTRAINT sipity_workflow_roles_pkey PRIMARY KEY (id);


--
-- Name: sipity_workflow_state_action_permissions sipity_workflow_state_action_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sipity_workflow_state_action_permissions
    ADD CONSTRAINT sipity_workflow_state_action_permissions_pkey PRIMARY KEY (id);


--
-- Name: sipity_workflow_state_actions sipity_workflow_state_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sipity_workflow_state_actions
    ADD CONSTRAINT sipity_workflow_state_actions_pkey PRIMARY KEY (id);


--
-- Name: sipity_workflow_states sipity_workflow_states_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sipity_workflow_states
    ADD CONSTRAINT sipity_workflow_states_pkey PRIMARY KEY (id);


--
-- Name: sipity_workflows sipity_workflows_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sipity_workflows
    ADD CONSTRAINT sipity_workflows_pkey PRIMARY KEY (id);


--
-- Name: tinymce_assets tinymce_assets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tinymce_assets
    ADD CONSTRAINT tinymce_assets_pkey PRIMARY KEY (id);


--
-- Name: trophies trophies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trophies
    ADD CONSTRAINT trophies_pkey PRIMARY KEY (id);


--
-- Name: uploaded_files uploaded_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.uploaded_files
    ADD CONSTRAINT uploaded_files_pkey PRIMARY KEY (id);


--
-- Name: user_stats user_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_stats
    ADD CONSTRAINT user_stats_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: version_committers version_committers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.version_committers
    ADD CONSTRAINT version_committers_pkey PRIMARY KEY (id);


--
-- Name: work_view_stats work_view_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.work_view_stats
    ADD CONSTRAINT work_view_stats_pkey PRIMARY KEY (id);


--
-- Name: by_file_set_id_and_file_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX by_file_set_id_and_file_id ON public.checksum_audit_logs USING btree (file_set_id, file_id);


--
-- Name: hyrax_collection_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX hyrax_collection_type_id ON public.collection_type_participants USING btree (hyrax_collection_type_id);


--
-- Name: index_bookmarks_on_document_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bookmarks_on_document_id ON public.bookmarks USING btree (document_id);


--
-- Name: index_bookmarks_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bookmarks_on_user_id ON public.bookmarks USING btree (user_id);


--
-- Name: index_checksum_audit_logs_on_checked_uri; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_checksum_audit_logs_on_checked_uri ON public.checksum_audit_logs USING btree (checked_uri);


--
-- Name: index_curation_concerns_operations_on_lft; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_curation_concerns_operations_on_lft ON public.curation_concerns_operations USING btree (lft);


--
-- Name: index_curation_concerns_operations_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_curation_concerns_operations_on_parent_id ON public.curation_concerns_operations USING btree (parent_id);


--
-- Name: index_curation_concerns_operations_on_rgt; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_curation_concerns_operations_on_rgt ON public.curation_concerns_operations USING btree (rgt);


--
-- Name: index_curation_concerns_operations_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_curation_concerns_operations_on_user_id ON public.curation_concerns_operations USING btree (user_id);


--
-- Name: index_featured_collections_on_collection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_featured_collections_on_collection_id ON public.featured_collections USING btree (collection_id);


--
-- Name: index_featured_collections_on_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_featured_collections_on_order ON public.featured_collections USING btree ("order");


--
-- Name: index_featured_works_on_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_featured_works_on_order ON public.featured_works USING btree ("order");


--
-- Name: index_featured_works_on_work_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_featured_works_on_work_id ON public.featured_works USING btree (work_id);


--
-- Name: index_file_download_stats_on_file_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_file_download_stats_on_file_id ON public.file_download_stats USING btree (file_id);


--
-- Name: index_file_download_stats_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_file_download_stats_on_user_id ON public.file_download_stats USING btree (user_id);


--
-- Name: index_file_view_stats_on_file_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_file_view_stats_on_file_id ON public.file_view_stats USING btree (file_id);


--
-- Name: index_file_view_stats_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_file_view_stats_on_user_id ON public.file_view_stats USING btree (user_id);


--
-- Name: index_hyrax_collection_types_on_machine_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_hyrax_collection_types_on_machine_id ON public.hyrax_collection_types USING btree (machine_id);


--
-- Name: index_job_io_wrappers_on_uploaded_file_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_io_wrappers_on_uploaded_file_id ON public.job_io_wrappers USING btree (uploaded_file_id);


--
-- Name: index_job_io_wrappers_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_job_io_wrappers_on_user_id ON public.job_io_wrappers USING btree (user_id);


--
-- Name: index_mailboxer_conversation_opt_outs_on_conversation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_mailboxer_conversation_opt_outs_on_conversation_id ON public.mailboxer_conversation_opt_outs USING btree (conversation_id);


--
-- Name: index_mailboxer_conversation_opt_outs_on_unsubscriber_id_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_mailboxer_conversation_opt_outs_on_unsubscriber_id_type ON public.mailboxer_conversation_opt_outs USING btree (unsubscriber_id, unsubscriber_type);


--
-- Name: index_mailboxer_notifications_on_conversation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_mailboxer_notifications_on_conversation_id ON public.mailboxer_notifications USING btree (conversation_id);


--
-- Name: index_mailboxer_notifications_on_notified_object_id_and_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_mailboxer_notifications_on_notified_object_id_and_type ON public.mailboxer_notifications USING btree (notified_object_id, notified_object_type);


--
-- Name: index_mailboxer_notifications_on_sender_id_and_sender_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_mailboxer_notifications_on_sender_id_and_sender_type ON public.mailboxer_notifications USING btree (sender_id, sender_type);


--
-- Name: index_mailboxer_notifications_on_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_mailboxer_notifications_on_type ON public.mailboxer_notifications USING btree (type);


--
-- Name: index_mailboxer_receipts_on_notification_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_mailboxer_receipts_on_notification_id ON public.mailboxer_receipts USING btree (notification_id);


--
-- Name: index_mailboxer_receipts_on_receiver_id_and_receiver_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_mailboxer_receipts_on_receiver_id_and_receiver_type ON public.mailboxer_receipts USING btree (receiver_id, receiver_type);


--
-- Name: index_minter_states_on_namespace; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_minter_states_on_namespace ON public.minter_states USING btree (namespace);


--
-- Name: index_permission_template_accesses_on_permission_template_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_permission_template_accesses_on_permission_template_id ON public.permission_template_accesses USING btree (permission_template_id);


--
-- Name: index_permission_templates_on_source_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_permission_templates_on_source_id ON public.permission_templates USING btree (source_id);


--
-- Name: index_proxy_deposit_requests_on_receiving_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_proxy_deposit_requests_on_receiving_user_id ON public.proxy_deposit_requests USING btree (receiving_user_id);


--
-- Name: index_proxy_deposit_requests_on_sending_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_proxy_deposit_requests_on_sending_user_id ON public.proxy_deposit_requests USING btree (sending_user_id);


--
-- Name: index_proxy_deposit_rights_on_grantee_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_proxy_deposit_rights_on_grantee_id ON public.proxy_deposit_rights USING btree (grantee_id);


--
-- Name: index_proxy_deposit_rights_on_grantor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_proxy_deposit_rights_on_grantor_id ON public.proxy_deposit_rights USING btree (grantor_id);


--
-- Name: index_qa_local_authorities_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_qa_local_authorities_on_name ON public.qa_local_authorities USING btree (name);


--
-- Name: index_qa_local_authority_entries_on_local_authority_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_qa_local_authority_entries_on_local_authority_id ON public.qa_local_authority_entries USING btree (local_authority_id);


--
-- Name: index_qa_local_authority_entries_on_uri; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_qa_local_authority_entries_on_uri ON public.qa_local_authority_entries USING btree (uri);


--
-- Name: index_roles_users_on_role_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_roles_users_on_role_id_and_user_id ON public.roles_users USING btree (role_id, user_id);


--
-- Name: index_roles_users_on_user_id_and_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_roles_users_on_user_id_and_role_id ON public.roles_users USING btree (user_id, role_id);


--
-- Name: index_searches_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_searches_on_user_id ON public.searches USING btree (user_id);


--
-- Name: index_sipity_comments_on_agent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sipity_comments_on_agent_id ON public.sipity_comments USING btree (agent_id);


--
-- Name: index_sipity_comments_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sipity_comments_on_created_at ON public.sipity_comments USING btree (created_at);


--
-- Name: index_sipity_comments_on_entity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sipity_comments_on_entity_id ON public.sipity_comments USING btree (entity_id);


--
-- Name: index_sipity_entities_on_workflow_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sipity_entities_on_workflow_id ON public.sipity_entities USING btree (workflow_id);


--
-- Name: index_sipity_entities_on_workflow_state_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sipity_entities_on_workflow_state_id ON public.sipity_entities USING btree (workflow_state_id);


--
-- Name: index_sipity_notifications_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_sipity_notifications_on_name ON public.sipity_notifications USING btree (name);


--
-- Name: index_sipity_notifications_on_notification_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sipity_notifications_on_notification_type ON public.sipity_notifications USING btree (notification_type);


--
-- Name: index_sipity_roles_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_sipity_roles_on_name ON public.sipity_roles USING btree (name);


--
-- Name: index_sipity_workflow_methods_on_workflow_action_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sipity_workflow_methods_on_workflow_action_id ON public.sipity_workflow_methods USING btree (workflow_action_id);


--
-- Name: index_sipity_workflow_states_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sipity_workflow_states_on_name ON public.sipity_workflow_states USING btree (name);


--
-- Name: index_sipity_workflows_on_permission_template_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_sipity_workflows_on_permission_template_and_name ON public.sipity_workflows USING btree (permission_template_id, name);


--
-- Name: index_uploaded_files_on_file_set_uri; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_uploaded_files_on_file_set_uri ON public.uploaded_files USING btree (file_set_uri);


--
-- Name: index_uploaded_files_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_uploaded_files_on_user_id ON public.uploaded_files USING btree (user_id);


--
-- Name: index_user_stats_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_stats_on_user_id ON public.user_stats USING btree (user_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_username; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_username ON public.users USING btree (username);


--
-- Name: index_work_view_stats_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_work_view_stats_on_user_id ON public.work_view_stats USING btree (user_id);


--
-- Name: index_work_view_stats_on_work_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_work_view_stats_on_work_id ON public.work_view_stats USING btree (work_id);


--
-- Name: mailboxer_notifications_notified_object; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mailboxer_notifications_notified_object ON public.mailboxer_notifications USING btree (notified_object_type, notified_object_id);


--
-- Name: sipity_agents_proxy_for; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sipity_agents_proxy_for ON public.sipity_agents USING btree (proxy_for_id, proxy_for_type);


--
-- Name: sipity_entities_proxy_for_global_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sipity_entities_proxy_for_global_id ON public.sipity_entities USING btree (proxy_for_global_id);


--
-- Name: sipity_entity_specific_responsibilities_agent; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sipity_entity_specific_responsibilities_agent ON public.sipity_entity_specific_responsibilities USING btree (agent_id);


--
-- Name: sipity_entity_specific_responsibilities_aggregate; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sipity_entity_specific_responsibilities_aggregate ON public.sipity_entity_specific_responsibilities USING btree (workflow_role_id, entity_id, agent_id);


--
-- Name: sipity_entity_specific_responsibilities_entity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sipity_entity_specific_responsibilities_entity ON public.sipity_entity_specific_responsibilities USING btree (entity_id);


--
-- Name: sipity_entity_specific_responsibilities_role; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sipity_entity_specific_responsibilities_role ON public.sipity_entity_specific_responsibilities USING btree (workflow_role_id);


--
-- Name: sipity_notifiable_contexts_concern; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sipity_notifiable_contexts_concern ON public.sipity_notifiable_contexts USING btree (scope_for_notification_id, scope_for_notification_type);


--
-- Name: sipity_notifiable_contexts_concern_context; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sipity_notifiable_contexts_concern_context ON public.sipity_notifiable_contexts USING btree (scope_for_notification_id, scope_for_notification_type, reason_for_notification);


--
-- Name: sipity_notifiable_contexts_concern_surrogate; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sipity_notifiable_contexts_concern_surrogate ON public.sipity_notifiable_contexts USING btree (scope_for_notification_id, scope_for_notification_type, reason_for_notification, notification_id);


--
-- Name: sipity_notifiable_contexts_notification_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sipity_notifiable_contexts_notification_id ON public.sipity_notifiable_contexts USING btree (notification_id);


--
-- Name: sipity_notification_recipients_notification; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sipity_notification_recipients_notification ON public.sipity_notification_recipients USING btree (notification_id);


--
-- Name: sipity_notification_recipients_recipient_strategy; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sipity_notification_recipients_recipient_strategy ON public.sipity_notification_recipients USING btree (recipient_strategy);


--
-- Name: sipity_notification_recipients_role; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sipity_notification_recipients_role ON public.sipity_notification_recipients USING btree (role_id);


--
-- Name: sipity_notifications_recipients_surrogate; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sipity_notifications_recipients_surrogate ON public.sipity_notification_recipients USING btree (notification_id, role_id, recipient_strategy);


--
-- Name: sipity_type_state_aggregate; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sipity_type_state_aggregate ON public.sipity_workflow_states USING btree (workflow_id, name);


--
-- Name: sipity_workflow_actions_aggregate; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sipity_workflow_actions_aggregate ON public.sipity_workflow_actions USING btree (workflow_id, name);


--
-- Name: sipity_workflow_actions_resulting_workflow_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sipity_workflow_actions_resulting_workflow_state ON public.sipity_workflow_actions USING btree (resulting_workflow_state_id);


--
-- Name: sipity_workflow_actions_workflow; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sipity_workflow_actions_workflow ON public.sipity_workflow_actions USING btree (workflow_id);


--
-- Name: sipity_workflow_responsibilities_aggregate; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sipity_workflow_responsibilities_aggregate ON public.sipity_workflow_responsibilities USING btree (agent_id, workflow_role_id);


--
-- Name: sipity_workflow_roles_aggregate; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sipity_workflow_roles_aggregate ON public.sipity_workflow_roles USING btree (workflow_id, role_id);


--
-- Name: sipity_workflow_state_action_permissions_aggregate; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sipity_workflow_state_action_permissions_aggregate ON public.sipity_workflow_state_action_permissions USING btree (workflow_role_id, workflow_state_action_id);


--
-- Name: sipity_workflow_state_actions_aggregate; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX sipity_workflow_state_actions_aggregate ON public.sipity_workflow_state_actions USING btree (originating_workflow_state_id, workflow_action_id);


--
-- Name: uk_permission_template_accesses; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uk_permission_template_accesses ON public.permission_template_accesses USING btree (permission_template_id, agent_id, agent_type, access);


--
-- Name: collection_type_participants fk_rails_2da4e10612; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_type_participants
    ADD CONSTRAINT fk_rails_2da4e10612 FOREIGN KEY (hyrax_collection_type_id) REFERENCES public.hyrax_collection_types(id);


--
-- Name: curation_concerns_operations fk_rails_3c63b420e5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.curation_concerns_operations
    ADD CONSTRAINT fk_rails_3c63b420e5 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: permission_template_accesses fk_rails_9c1ccdc6d5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permission_template_accesses
    ADD CONSTRAINT fk_rails_9c1ccdc6d5 FOREIGN KEY (permission_template_id) REFERENCES public.permission_templates(id);


--
-- Name: qa_local_authority_entries fk_rails_cee742275b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.qa_local_authority_entries
    ADD CONSTRAINT fk_rails_cee742275b FOREIGN KEY (local_authority_id) REFERENCES public.qa_local_authorities(id);


--
-- Name: uploaded_files fk_rails_ece9dfb06e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.uploaded_files
    ADD CONSTRAINT fk_rails_ece9dfb06e FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: mailboxer_conversation_opt_outs mb_opt_outs_on_conversations_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mailboxer_conversation_opt_outs
    ADD CONSTRAINT mb_opt_outs_on_conversations_id FOREIGN KEY (conversation_id) REFERENCES public.mailboxer_conversations(id);


--
-- Name: mailboxer_notifications notifications_on_conversation_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mailboxer_notifications
    ADD CONSTRAINT notifications_on_conversation_id FOREIGN KEY (conversation_id) REFERENCES public.mailboxer_conversations(id);


--
-- Name: mailboxer_receipts receipts_on_notification_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mailboxer_receipts
    ADD CONSTRAINT receipts_on_notification_id FOREIGN KEY (notification_id) REFERENCES public.mailboxer_notifications(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20171220142811'),
('20171220142812'),
('20171220142813'),
('20171220142820'),
('20171220142823'),
('20171220142850'),
('20171220142851'),
('20171220142852'),
('20171220142853'),
('20171220142854'),
('20171220142855'),
('20171220142856'),
('20171220142857'),
('20171220142858'),
('20171220142859'),
('20171220142860'),
('20171220142861'),
('20171220142862'),
('20171220142863'),
('20171220142864'),
('20171220142865'),
('20171220142866'),
('20171220142867'),
('20171220142868'),
('20171220142869'),
('20171220142870'),
('20171220142871'),
('20171220142872'),
('20171220142873'),
('20171220142874'),
('20171220142875'),
('20171220142876'),
('20171220142877'),
('20171220142878'),
('20171220142879'),
('20171220142880'),
('20171220142881'),
('20171220142882'),
('20171220142883'),
('20171220142884'),
('20171220142885'),
('20171220142886'),
('20171220142887'),
('20171220142888'),
('20171220142889'),
('20171220142890'),
('20171220142891'),
('20171220142892'),
('20171220142893'),
('20171220142894'),
('20171220142902'),
('20171220142903'),
('20171220142912'),
('20171220142913'),
('20171220154522'),
('20180427181333'),
('20180427181334'),
('20180427181335'),
('20180427181336'),
('20180427181337'),
('20180427181338'),
('20180427181339'),
('20180427181340'),
('20180427181341'),
('20181101155934'),
('20190220133607'),
('20190315143022'),
('20190327194742'),
('20200128221650');


