SET ECHO OFF
SET TERMOUT OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET LINESIZE 2000
SET TRIMSPOOL ON
COL filename new_value filename
SELECT 'U:\Data\COMPLETED_'||TO_CHAR(SYSDATE,'MMDDYYYY')||'.TXT' filename FROM DUAL;
SPOOL &&filename
PROMPT APP_ID^FORM_NBR^OFFICE_LOC_CODE^OFFICE_LOC_SUB_CODE^CASE_LOC_CODE^CASE_LOC_SUB_CODE^ALIEN_NBR^LAST_NAME^FIRST_NAME^MIDDLE_NAME^DOB_DT^MR_RECV_DTIME^COB_CODE^CITIZENSHIP_CNTRY_CODE^PERMRES_DT^DISABILITY_FLAG^FORM_N648_ATTACHED_FLAG^ELIGIBILITY_CODE^PROC_STATUS^COMPLETION_DATE^CURR_ACT^CURR_ACT_DATE^ACT_COMPLETE^ACTIVITY_DATE
SELECT
apl.APP_ID||'^'||
apl.FORM_NBR||'^'||
proc.OFFICE_LOC_CODE||'^'||
proc.OFFICE_LOC_SUB_CODE||'^'||
proc.CASE_LOC_CODE||'^'||
proc.CASE_LOC_SUB_CODE||'^'||
applic.ALIEN_NBR||'^'||
applic.LAST_NAME||'^'||
applic.FIRST_NAME||'^'||
applic.MIDDLE_NAME||'^'||
TO_CHAR(applic.DOB_DT,'MM/DD/YYYY')||'^'||
TO_CHAR(apl.MR_RECV_DTIME,'MM/DD/YYYY')||'^'||
applic.COB_CODE||'^'||
applic.CITIZENSHIP_CNTRY_CODE||'^'||
TO_CHAR(applic.PERMRES_DT,'MM/DD/YYYY')||'^'||
decode(apl.DISABILITY_FLAG,'N','','Y','D') || 
   decode(apl.HEARING_IMPAIRED_FLAG,'N','','Y','H') || 
   decode(apl.WHEEL_CHAIR_FLAG,'N','','Y','W') ||
   decode(apl.VISION_IMPAIRED_FLAG,'N','','Y','V') || 
   decode(apl.OTHER_DISABILITY_FLAG, 'N','','Y','O')||'^'||
apl.FORM_N648_ATTACHED_FLAG||'^'||
apl.PART21_CODE||'^'||
proc.process_state||'^'||
TO_CHAR(proc.end_dtime,'MM/DD/YYYY')||'^'||
wf.act_code||'^'||
TO_CHAR(wf.state_dtime,'MM/DD/YYYY')||'^'||
'Natz'||'^'||
TO_CHAR(apl.natz_dt,'MM/DD/YYYY')
FROM 
IBS_AP_APPLICATION apl,
IBS_AP_APPLICANT applic,
IBS_WF_ACT_INST wf,
IBS_WF_PROCESS_INST proc
WHERE 
apl.APP_ID = applic.APP_ID
AND apl.APP_ID = proc.PROCESS_INST_ID
AND apl.APP_ID = wf.PROCESS_INST_ID
-- DWP 2017/06/29 USCISC4-342: Excluding military, military spouse, and BCT cases
AND (apl.MILITARY IS NULL OR apl.MILITARY <> 'Y')
AND (apl.MILITARY_SPOUSE IS NULL OR apl.MILITARY_SPOUSE <> 'Y')
AND (apl.BCT_INDICATOR IS NULL OR apl.BCT_INDICATOR <> 'Y')
AND apl.FORM_NBR = 'N400'
AND proc.process_state <> 'Terminated'
AND wf.ACT_INST_ID =  (SELECT MAX(ACT_INST_ID) 
                          FROM IBS_WF_ACT_INST wf1
                          WHERE wf1.PROCESS_INST_ID = PROC.PROCESS_INST_ID ) 
AND EXISTS (SELECT 1 from IBS_WF_ACT_INST_STATE wfs, IBS_WF_END_COND_INST cond
        WHERE apl.app_id = wfs.process_inst_id
        and wfs.act_inst_id = cond.act_inst_id
        and wfs.act_code='OathCeremony'  
        and wfs.act_state='Completed' 
	and wfs.state_dtime >= sysdate -45
        AND cond.END_COND_CODE IN ('AdminClose','OathClose','OK','BDO'))
UNION
SELECT 
apl.APP_ID||'^'||
apl.FORM_NBR||'^'||
proc.OFFICE_LOC_CODE||'^'||
proc.OFFICE_LOC_SUB_CODE||'^'||
proc.CASE_LOC_CODE||'^'||
proc.CASE_LOC_SUB_CODE||'^'||
applic.ALIEN_NBR||'^'||
applic.LAST_NAME||'^'||
applic.FIRST_NAME||'^'||
applic.MIDDLE_NAME||'^'||
TO_CHAR(applic.DOB_DT,'MM/DD/YYYY')||'^'||
TO_CHAR(apl.MR_RECV_DTIME,'MM/DD/YYYY')||'^'||
applic.COB_CODE||'^'||
applic.CITIZENSHIP_CNTRY_CODE||'^'||
TO_CHAR(applic.PERMRES_DT,'MM/DD/YYYY')||'^'||
decode(apl.DISABILITY_FLAG,'N','','Y','D') || 
   decode(apl.HEARING_IMPAIRED_FLAG,'N','','Y','H') || 
   decode(apl.WHEEL_CHAIR_FLAG,'N','','Y','W') ||
   decode(apl.VISION_IMPAIRED_FLAG,'N','','Y','V') || 
   decode(apl.OTHER_DISABILITY_FLAG, 'N','','Y','O')||'^'||
apl.FORM_N648_ATTACHED_FLAG||'^'||
apl.PART21_CODE||'^'||
proc.process_state||'^'||
TO_CHAR(proc.end_dtime,'MM/DD/YYYY')||'^'||
''||'^'||
''||'^'||
'Natz'||'^'||
TO_CHAR(apl.natz_dt,'MM/DD/YYYY')
FROM 
IBS_AP_APPLICATION apl,
IBS_AP_APPLICANT applic,
IBS_WF_PROCESS_INST proc
WHERE 
apl.APP_ID = applic.APP_ID
AND apl.APP_ID = proc.PROCESS_INST_ID
-- DWP 2017/06/29 USCISC4-342: Excluding military, military spouse, and BCT cases
AND (apl.MILITARY IS NULL OR apl.MILITARY <> 'Y')
AND (apl.MILITARY_SPOUSE IS NULL OR apl.MILITARY_SPOUSE <> 'Y')
AND (apl.BCT_INDICATOR IS NULL OR apl.BCT_INDICATOR <> 'Y')
AND apl.FORM_NBR = 'N400'
AND proc.process_state = 'Completed'
AND EXISTS (SELECT 1 from IBS_WF_ACT_INST_STATE wfs, IBS_WF_END_COND_INST cond
        WHERE apl.app_id = wfs.process_inst_id
        and wfs.act_inst_id = cond.act_inst_id
        and wfs.act_code='OathCeremony'  
        and wfs.act_state='Completed' 
	and wfs.state_dtime >= sysdate -45
        AND cond.END_COND_CODE IN ('AdminClose','OathClose','OK','BDO'))
UNION
SELECT 
apl.APP_ID||'^'||
apl.FORM_NBR||'^'||
proc.OFFICE_LOC_CODE||'^'||
proc.OFFICE_LOC_SUB_CODE||'^'||
proc.CASE_LOC_CODE||'^'||
proc.CASE_LOC_SUB_CODE||'^'||
applic.ALIEN_NBR||'^'||
applic.LAST_NAME||'^'||
applic.FIRST_NAME||'^'||
applic.MIDDLE_NAME||'^'||
TO_CHAR(applic.DOB_DT,'MM/DD/YYYY')||'^'||
TO_CHAR(apl.MR_RECV_DTIME,'MM/DD/YYYY')||'^'||
applic.COB_CODE||'^'||
applic.CITIZENSHIP_CNTRY_CODE||'^'||
TO_CHAR(applic.PERMRES_DT,'MM/DD/YYYY')||'^'||
decode(apl.DISABILITY_FLAG,'N','','Y','D') || 
   decode(apl.HEARING_IMPAIRED_FLAG,'N','','Y','H') || 
   decode(apl.WHEEL_CHAIR_FLAG,'N','','Y','W') ||
   decode(apl.VISION_IMPAIRED_FLAG,'N','','Y','V') || 
   decode(apl.OTHER_DISABILITY_FLAG, 'N','','Y','O')||'^'||
apl.FORM_N648_ATTACHED_FLAG||'^'||
apl.PART21_CODE||'^'||
proc.process_state||'^'||
TO_CHAR(proc.end_dtime,'MM/DD/YYYY')||'^'||
''||'^'||
''||'^'||
'Citz'||'^'||
TO_CHAR(applic.citizenship_dt,'MM/DD/YYYY')
FROM 
IBS_AP_APPLICATION apl,
IBS_AP_APPLICANT applic,
IBS_WF_PROCESS_INST proc
WHERE 
apl.APP_ID = applic.APP_ID
AND apl.APP_ID = proc.PROCESS_INST_ID
-- DWP 2017/06/29 USCISC4-342: Excluding military, military spouse, and BCT cases
AND (apl.MILITARY IS NULL OR apl.MILITARY <> 'Y')
AND (apl.MILITARY_SPOUSE IS NULL OR apl.MILITARY_SPOUSE <> 'Y')
AND (apl.BCT_INDICATOR IS NULL OR apl.BCT_INDICATOR <> 'Y')
AND apl.FORM_NBR in ('N600','N600K')
AND EXISTS (SELECT 1 from IBS_WF_ACT_INST_STATE wfs
        WHERE apl.app_id = wfs.process_inst_id
        and wfs.act_code='CtNatzIssue'  
        and wfs.act_state='Completed'
	and wfs.state_dtime >= sysdate -45);
SPOOL OFF;
SET ECHO ON
SET TERMOUT ON
SET FEEDBACK ON