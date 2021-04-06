CREATE TABLE public."Territories"
(
	"terr_id" serial NOT NULL,
    "territory" text NOT NULL,
    "area" text NOT NULL,
    "region" text NOT NULL,
    "terr_type" text,
    PRIMARY KEY ("terr_id")
);

CREATE TABLE public."Educational_institutions"
(
	"institution_id" serial,
    "institution_name" text NOT NULL,
    "territory" serial NOT NULL,
    "ei_type" text NOT NULL,
    "parent_institution" text NOT NULL,
    PRIMARY KEY ("institution_id"),
    FOREIGN KEY ("territory")
        REFERENCES public."Territories" ("terr_id") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
);

CREATE TABLE public."Participants"
(
    "participant_id" text NOT NULL,
    "birthyear" integer NOT NULL,
    "sex" text NOT NULL,
    "territory" serial NOT NULL,
    "status" text NOT NULL,
    "education" text,
    "p_language" text,
    "educational_institution" serial,
    PRIMARY KEY ("participant_id"),
    FOREIGN KEY ("territory")
        REFERENCES public."Territories" ("terr_id") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    FOREIGN KEY ("educational_institution")
        REFERENCES public."Educational_institutions" ("institution_id") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
);

ALTER TABLE public."Participants"
    ALTER COLUMN educational_institution DROP NOT NULL;

CREATE TABLE public."ZNO_locations"
(
	"loc_id" serial NOT NULL,
    "zno_location" text NOT NULL,
    "territory" serial NOT NULL,
    PRIMARY KEY ("loc_id"),
    FOREIGN KEY ("territory")
        REFERENCES public."Territories" ("terr_id") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
);

CREATE TABLE public."Tests"
(
    test_id serial NOT NULL,
    participant_id text,
    subject text,
    t_language text,
    status text,
    mark_100 real,
    mark_12 integer,
    mark integer,
    adaptive_scale integer,
    test_location serial,
    test_year integer,
    PRIMARY KEY (test_id),
    FOREIGN KEY (participant_id)
        REFERENCES public."Participants" ("participant_id") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    FOREIGN KEY (test_location)
        REFERENCES public."ZNO_locations" ("loc_id") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
);

DO $$
BEGIN 
IF (SELECT COUNT(*)
FROM information_schema.tables 
WHERE table_name = 'hist_results')>0 THEN
INSERT INTO public."Territories"(territory, area, region, terr_type)	 
	SELECT "TERNAME", "AREANAME", "REGNAME", "TerTypeName" FROM public.hist_results
	UNION
	SELECT * FROM
	(SELECT "UkrPTTerName" AS "ter_name", "UkrPTAreaName" AS "area_name", "UkrPTRegName" AS "reg_name", null FROM public.hist_results	
	UNION
	SELECT "EOTerName", "EOAreaName", "EORegName", null FROM public.hist_results
	UNION
	SELECT "histPTTerName", "histPTAreaName", "Region", null FROM public.hist_results
	UNION
	SELECT "mathPTTerName", "mathPTAreaName", "mathPTRegName", null FROM public.hist_results
	UNION
	SELECT "physPTTerName", "physPTAreaName", "physPTRegName", null FROM public.hist_results
	UNION
	SELECT "chemPTTerName", "chemPTAreaName", "chemPTRegName", null FROM public.hist_results
	UNION
	SELECT "bioPTTerName", "bioPTAreaName", "bioPTRegName", null FROM public.hist_results
	UNION
	SELECT "geoPTTerName", "geoPTAreaName", "geoPTRegName", null FROM public.hist_results
	UNION
	SELECT "engPTTerName", "engPTAreaName", "engPTRegName", null FROM public.hist_results
	UNION
	SELECT "fraPTTerName", "fraPTAreaName", "fraPTRegName", null FROM public.hist_results
	UNION
	SELECT "deuPTTerName", "deuPTAreaName", "deuPTRegName", null FROM public.hist_results
	UNION
	SELECT "spaPTTerName", "spaPTAreaName", "spaPTRegName", null FROM public.hist_results) AS t
	WHERE "ter_name" IS NOT null AND ("ter_name", "area_name", "reg_name") NOT IN (SELECT DISTINCT "TERNAME", "AREANAME", "REGNAME" FROM public.hist_results);

INSERT INTO public."Educational_institutions"(institution_name, territory, ei_type, parent_institution)
	SELECT DISTINCT "EONAME", "terr_id", "EOTYPENAME", "EOParent" FROM public."hist_results"
	LEFT JOIN public."Territories" ON ("EORegName" = "region"
	AND "EOAreaName" = "area"
	AND "EOTerName" = "territory")
	WHERE "EONAME" IS NOT NULL;
	
INSERT INTO public."Participants"(participant_id, birthyear, sex, territory, status, education, p_language, educational_institution)
	SELECT "OutID", "Birth", "SEXTYPENAME", "terr_id", "REGTYPENAME", "ClassProfileNAME", "ClassLangName", "institution_id" FROM public."hist_results"
	LEFT JOIN public."Territories" ON ("REGNAME" = "region"
	AND "AREANAME" = "area"
	AND "TERNAME" = "territory"
	AND "TerTypeName" = "terr_type")
	LEFT JOIN public."Educational_institutions" ON ("institution_name" = "EONAME"
		AND "parent_institution" = "EOParent"
		AND "ei_type" = "EOTYPENAME"
		AND ("EORegName", "EOAreaName", "EOTerName") IN (
			SELECT region, area, territory FROM public."Territories" 
			WHERE terr_id = "Educational_institutions".territory));

INSERT INTO public."ZNO_locations"(zno_location, territory)
	SELECT ZNO_location, terr_id FROM(
		SELECT "UkrPTName" AS ZNO_location, "UkrPTTerName" AS "ter_name", "UkrPTAreaName" AS "area_name", "UkrPTRegName" AS "reg_name" FROM public."hist_results"
		UNION
		SELECT "histPTName", "histPTTerName", "histPTAreaName", "Region" FROM public."hist_results"
		UNION
		SELECT "mathPTName", "mathPTTerName", "mathPTAreaName", "mathPTRegName" FROM public."hist_results"
		UNION
		SELECT "physPTName", "physPTTerName", "physPTAreaName", "physPTRegName" FROM public."hist_results"
		UNION
		SELECT "chemPTName", "chemPTTerName", "chemPTAreaName", "chemPTRegName" FROM public."hist_results"
		UNION
		SELECT "bioPTName", "bioPTTerName", "bioPTAreaName", "bioPTRegName" FROM public."hist_results"
		UNION
		SELECT "geoPTName", "geoPTTerName", "geoPTAreaName", "geoPTRegName" FROM public."hist_results"
		UNION
		SELECT "engPTName", "engPTTerName", "engPTAreaName", "engPTRegName" FROM public."hist_results"
		UNION
		SELECT "fraPTName", "fraPTTerName", "fraPTAreaName", "fraPTRegName" FROM public."hist_results"
		UNION
		SELECT "deuPTName", "deuPTTerName", "deuPTAreaName", "deuPTRegName" FROM public."hist_results"
		UNION
		SELECT "spaPTName","spaPTTerName", "spaPTAreaName", "spaPTRegName" FROM public."hist_results"		
	) AS Combined_tests
	LEFT JOIN public."Territories" ON ("reg_name" = "region"
	AND "area_name" = "area"
	AND "ter_name" = "territory")
	WHERE ZNO_location IS NOT NULL;

INSERT INTO public."Tests"(participant_id, subject, t_language, status, mark_100, mark_12, mark, adaptive_scale, test_location, test_year)
	SELECT "OutID", "UkrTest", "t_language", "UkrTestStatus", "UkrBall100", "UkrBall12", "UkrBall", "UkrAdaptScale", "loc_id", "Year" FROM(
		SELECT "OutID", "UkrTest", 'українська' AS "t_language", "UkrTestStatus", "UkrBall100", "UkrBall12", "UkrBall", "UkrAdaptScale", "Year", "UkrPTName" AS ZNO_loc, "UkrPTTerName" AS "ter_name", "UkrPTAreaName" AS "area_name", "UkrPTRegName" AS "reg_name" FROM public."hist_results"
		UNION
		SELECT "OutID", "histTest", "HistLang", "Status", "Score", "histBall12", "histBall", NULL, "Year", "histPTName", "histPTTerName", "histPTAreaName", "Region" FROM public."hist_results"
		UNION
		SELECT "OutID", "mathTest", "mathLang", "mathTestStatus", "mathBall100", "mathBall12", "mathBall", NULL, "Year", "mathPTName", "mathPTTerName", "mathPTAreaName", "mathPTRegName" FROM public."hist_results"
		UNION
		SELECT "OutID", "physTest", "physLang", "physTestStatus", "physBall100", "physBall12", "physBall", NULL, "Year", "physPTName", "physPTTerName", "physPTAreaName", "physPTRegName" FROM public."hist_results"
		UNION
		SELECT "OutID", "chemTest", "chemLang", "chemTestStatus", "chemBall100", "chemBall12", "chemBall", NULL, "Year", "chemPTName", "chemPTTerName", "chemPTAreaName", "chemPTRegName" FROM public."hist_results"
		UNION
		SELECT "OutID", "bioTest", "bioLang", "bioTestStatus", "bioBall100", "bioBall12", "bioBall", NULL, "Year", "bioPTName", "bioPTTerName", "bioPTAreaName", "bioPTRegName" FROM public."hist_results"
		UNION
		SELECT "OutID", "geoTest", "geoLang", "geoTestStatus", "geoBall100", "geoBall12", "geoBall", NULL, "Year", "geoPTName", "geoPTTerName", "geoPTAreaName", "geoPTRegName" FROM public."hist_results"
		UNION
		SELECT "OutID", "engTest", 'англійська', "engTestStatus", "engBall100", "engBall12", "engBall", NULL, "Year", "engPTName", "engPTTerName", "engPTAreaName", "engPTRegName" FROM public."hist_results"
		UNION
		SELECT "OutID", "fraTest", 'французька', "fraTestStatus", "fraBall100", "fraBall12", "fraBall", NULL, "Year", "fraPTName", "fraPTTerName", "fraPTAreaName", "fraPTRegName" FROM public."hist_results"
		UNION
		SELECT "OutID", "deuTest", 'німецька', "deuTestStatus", "deuBall100", "deuBall12", "deuBall", NULL, "Year", "deuPTName", "deuPTTerName", "deuPTAreaName", "deuPTRegName" FROM public."hist_results"
		UNION
		SELECT "OutID", "spaTest", 'іспанська', "spaTestStatus", "spaBall100", "spaBall12", "spaBall", NULL, "Year", "spaPTName","spaPTTerName", "spaPTAreaName", "spaPTRegName" FROM public."hist_results") AS Combined_tests
		LEFT JOIN public."ZNO_locations" ON ZNO_loc = zno_location
		WHERE "UkrTest" IS NOT NULL;
END IF;
END $$
