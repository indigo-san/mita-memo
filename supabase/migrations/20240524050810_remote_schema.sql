
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

CREATE EXTENSION IF NOT EXISTS "pgsodium" WITH SCHEMA "pgsodium";

COMMENT ON SCHEMA "public" IS 'standard public schema';

CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";

CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";

SET default_tablespace = '';

SET default_table_access_method = "heap";

CREATE TABLE IF NOT EXISTS "public"."animes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "name" "text" NOT NULL,
    "episodes" integer NOT NULL,
    "description" "text",
    "cover_img" "text",
    "url" "text"
);

ALTER TABLE "public"."animes" OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."get_unwatched_animes"() RETURNS SETOF "public"."animes"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    RETURN QUERY 
    SELECT animes.*
    FROM animes
    INNER JOIN records
    ON animes.id != records.anime_id;
END; $$;

ALTER FUNCTION "public"."get_unwatched_animes"() OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."get_watched_animes"() RETURNS SETOF "public"."animes"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    RETURN QUERY 
    SELECT animes.*
    FROM animes
    INNER JOIN records
    ON animes.id = records.anime_id;
END; $$;

ALTER FUNCTION "public"."get_watched_animes"() OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."is_in_role"("role" "text") RETURNS integer
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    RETURN count(*) from user_roles
    INNER JOIN roles
    ON roles.id = user_roles.role_id
    WHERE name = role;
END; $$;

ALTER FUNCTION "public"."is_in_role"("role" "text") OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."update_timestamp"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

ALTER FUNCTION "public"."update_timestamp"() OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."records" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "user_id" "uuid" DEFAULT "gen_random_uuid"(),
    "anime_id" "uuid" DEFAULT "gen_random_uuid"(),
    "episode_number" integer,
    "note" "text",
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);

ALTER TABLE "public"."records" OWNER TO "postgres";

ALTER TABLE "public"."records" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."records_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE IF NOT EXISTS "public"."requests" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "name" "text" NOT NULL,
    "url" "text",
    "user_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL
);

ALTER TABLE "public"."requests" OWNER TO "postgres";

ALTER TABLE "public"."requests" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."requests_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE IF NOT EXISTS "public"."response4request" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "message" "text",
    "reject" boolean,
    "request_id" bigint,
    "user_id" "uuid"
);

ALTER TABLE "public"."response4request" OWNER TO "postgres";

ALTER TABLE "public"."response4request" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."response4request_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE IF NOT EXISTS "public"."roles" (
    "id" bigint NOT NULL,
    "name" "text" NOT NULL
);

ALTER TABLE "public"."roles" OWNER TO "postgres";

ALTER TABLE "public"."roles" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."roles_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE IF NOT EXISTS "public"."user_roles" (
    "role_id" bigint NOT NULL,
    "user_id" "uuid" NOT NULL
);

ALTER TABLE "public"."user_roles" OWNER TO "postgres";

ALTER TABLE ONLY "public"."animes"
    ADD CONSTRAINT "animes_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."records"
    ADD CONSTRAINT "records_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."requests"
    ADD CONSTRAINT "requests_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."response4request"
    ADD CONSTRAINT "response4request_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."roles"
    ADD CONSTRAINT "roles_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."user_roles"
    ADD CONSTRAINT "user_roles_pkey" PRIMARY KEY ("role_id", "user_id");

CREATE OR REPLACE TRIGGER "update_your_table_modtime" BEFORE UPDATE ON "public"."records" FOR EACH ROW EXECUTE FUNCTION "public"."update_timestamp"();

ALTER TABLE ONLY "public"."records"
    ADD CONSTRAINT "records_anime_id_fkey" FOREIGN KEY ("anime_id") REFERENCES "public"."animes"("id") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."records"
    ADD CONSTRAINT "records_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."requests"
    ADD CONSTRAINT "requests_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."response4request"
    ADD CONSTRAINT "response4request_request_id_fkey" FOREIGN KEY ("request_id") REFERENCES "public"."requests"("id") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."response4request"
    ADD CONSTRAINT "response4request_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."user_roles"
    ADD CONSTRAINT "user_roles_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "public"."roles"("id") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."user_roles"
    ADD CONSTRAINT "user_roles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;

CREATE POLICY "Enable control for moderator" ON "public"."animes" USING (( SELECT ("public"."is_in_role"('moderator'::"text") = 1)));

CREATE POLICY "Enable control for moderator" ON "public"."response4request" USING (( SELECT ("public"."is_in_role"('moderator'::"text") = 1)));

CREATE POLICY "Enable delete for users based on user_id" ON "public"."records" FOR DELETE USING ((( SELECT "auth"."uid"() AS "uid") = "user_id"));

CREATE POLICY "Enable delete for users based on user_id" ON "public"."requests" FOR DELETE USING ((( SELECT "auth"."uid"() AS "uid") = "user_id"));

CREATE POLICY "Enable insert for users based on user_id" ON "public"."records" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "user_id"));

CREATE POLICY "Enable insert for users based on user_id" ON "public"."requests" FOR INSERT WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "user_id"));

CREATE POLICY "Enable read access for all users" ON "public"."animes" FOR SELECT USING (true);

CREATE POLICY "Enable select for authenticated users only" ON "public"."roles" FOR SELECT TO "authenticated" USING (true);

CREATE POLICY "Enable select for users based on user_id" ON "public"."records" FOR SELECT USING ((( SELECT "auth"."uid"() AS "uid") = "user_id"));

CREATE POLICY "Enable select for users based on user_id" ON "public"."requests" FOR SELECT USING ((( SELECT "auth"."uid"() AS "uid") = "user_id"));

CREATE POLICY "Enable select for users based on user_id" ON "public"."response4request" FOR SELECT USING ((( SELECT "auth"."uid"() AS "uid") = "user_id"));

CREATE POLICY "Enable select for users based on user_id" ON "public"."user_roles" FOR SELECT USING ((( SELECT "auth"."uid"() AS "uid") = "user_id"));

CREATE POLICY "Enable update for users based on user_id" ON "public"."records" FOR UPDATE USING ((( SELECT "auth"."uid"() AS "uid") = "user_id"));

ALTER TABLE "public"."animes" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."records" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."requests" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."response4request" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."roles" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."user_roles" ENABLE ROW LEVEL SECURITY;

ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";

GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";

GRANT ALL ON TABLE "public"."animes" TO "anon";
GRANT ALL ON TABLE "public"."animes" TO "authenticated";
GRANT ALL ON TABLE "public"."animes" TO "service_role";

GRANT ALL ON FUNCTION "public"."get_unwatched_animes"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_unwatched_animes"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_unwatched_animes"() TO "service_role";

GRANT ALL ON FUNCTION "public"."get_watched_animes"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_watched_animes"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_watched_animes"() TO "service_role";

GRANT ALL ON FUNCTION "public"."is_in_role"("role" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."is_in_role"("role" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_in_role"("role" "text") TO "service_role";

GRANT ALL ON FUNCTION "public"."update_timestamp"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_timestamp"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_timestamp"() TO "service_role";

GRANT ALL ON TABLE "public"."records" TO "anon";
GRANT ALL ON TABLE "public"."records" TO "authenticated";
GRANT ALL ON TABLE "public"."records" TO "service_role";

GRANT ALL ON SEQUENCE "public"."records_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."records_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."records_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."requests" TO "anon";
GRANT ALL ON TABLE "public"."requests" TO "authenticated";
GRANT ALL ON TABLE "public"."requests" TO "service_role";

GRANT ALL ON SEQUENCE "public"."requests_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."requests_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."requests_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."response4request" TO "anon";
GRANT ALL ON TABLE "public"."response4request" TO "authenticated";
GRANT ALL ON TABLE "public"."response4request" TO "service_role";

GRANT ALL ON SEQUENCE "public"."response4request_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."response4request_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."response4request_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."roles" TO "anon";
GRANT ALL ON TABLE "public"."roles" TO "authenticated";
GRANT ALL ON TABLE "public"."roles" TO "service_role";

GRANT ALL ON SEQUENCE "public"."roles_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."roles_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."roles_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."user_roles" TO "anon";
GRANT ALL ON TABLE "public"."user_roles" TO "authenticated";
GRANT ALL ON TABLE "public"."user_roles" TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";

RESET ALL;
