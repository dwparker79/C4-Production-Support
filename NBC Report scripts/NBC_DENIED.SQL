SET ECHO OFF
SET TERMOUT OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET LINESIZE 2000
SET TRIMSPOOL ON
COL filename new_value filename
SELECT 'U:\Data\C4_DENIED_'||TO_CHAR(SYSDATE,'MMDDYYYY')||'.TXT' filename FROM DUAL;
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
wf.ACT_CODE||'^'||
TO_CHAR(wf.STATE_DTIME,'MM/DD/YYYY')||'^'||
DECODE(adj.END_COND_CODE, 'AjAdminClose', 'Admin Closed', 
	'Terminate', 'Admin Closed',  'Withdrawn', 'Withdrawn', 
	'Deny', 'Denied', 'AbnB', 'Abandoned', 'AbnI', 'Abandoned')||'^'||
TO_CHAR(adj.rslt_dtime,'MM/DD/YYYY')
FROM 
IBS_AP_APPLICATION apl,
IBS_AP_APPLICANT applic,
IBS_WF_PROCESS_INST proc,
IBS_AP_ADJ_RSLT adj,
IBS_WF_ACT_INST wf
WHERE 
apl.APP_ID = applic.APP_ID
AND apl.APP_ID = proc.PROCESS_INST_ID
AND apl.APP_ID = adj.APP_ID
AND apl.APP_ID = wf.PROCESS_INST_ID (+) 
-- DWP 2017/06/29 USCISC4-342: Excluding military, military spouse, and BCT cases
AND NVL(apl.MILITARY, 'N') <> 'Y'
AND NVL(apl.MILITARY_SPOUSE, 'N') <> 'Y'
AND NVL(apl.BCT_INDICATOR, 'N') <> 'Y'
AND apl.FORM_NBR in ('N336','N400','N600','N600K')
AND proc.process_state <> 'Terminated'
AND adj.END_COND_CODE IN ('AjAdminClose','Terminate','Withdrawn','Deny','AbnB','AbnI') 
AND adj.rslt_dtime > sysdate -30
AND adj.ACT_INST_ID =  (SELECT MAX(ACT_INST_ID) 
                          FROM IBS_AP_ADJ_RSLT adj1
                          WHERE adj1.APP_ID = PROC.PROCESS_INST_ID )  
AND wf.ACT_INST_ID =  (SELECT MAX(ACT_INST_ID) 
                          FROM IBS_WF_ACT_INST wf1
                          WHERE wf1.PROCESS_INST_ID = PROC.PROCESS_INST_ID ) 
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
decode(apl.DISABILITY_FLAG,'N','','Y','*') || 
   decode(apl.HEARING_IMPAIRED_FLAG,'N','','Y','*') || 
   decode(apl.WHEEL_CHAIR_FLAG,'N','','Y','*') ||
   decode(apl.VISION_IMPAIRED_FLAG,'N','','Y','*') || 
   decode(apl.OTHER_DISABILITY_FLAG, 'N','','Y','*')||'^'||
apl.FORM_N648_ATTACHED_FLAG||'^'||
apl.PART21_CODE||'^'||
proc.process_state||'^'||
TO_CHAR(proc.end_dtime,'MM/DD/YYYY')||'^'||
''||'^'||
''||'^'||
DECODE(adj.END_COND_CODE, 'AjAdminClose', 'Admin Closed', 
	'Terminate', 'Admin Closed',  'Withdrawn', 'Withdrawn', 
	'Deny', 'Denied', 'AbnB', 'Abandoned', 'AbnI', 'Abandoned')||'^'||
TO_CHAR(adj.rslt_dtime,'MM/DD/YYYY') 
FROM  
IBS_AP_APPLICATION apl,
IBS_AP_APPLICANT applic,
IBS_WF_PROCESS_INST proc,
IBS_AP_ADJ_RSLT adj
WHERE 
apl.APP_ID = applic.APP_ID
AND apl.APP_ID = proc.PROCESS_INST_ID
AND apl.APP_ID = adj.APP_ID
-- DWP 2017/06/29 USCISC4-342: Excluding military, military spouse, and BCT cases
AND NVL(apl.MILITARY, 'N') <> 'Y'
AND NVL(apl.MILITARY_SPOUSE, 'N') <> 'Y'
AND NVL(apl.BCT_INDICATOR, 'N') <> 'Y'
AND apl.FORM_NBR in ('N336','N400','N600','N600K')
AND proc.process_state <> 'Terminated'
AND adj.END_COND_CODE IN ('AjAdminClose','Terminate','Withdrawn','Deny','AbnB','AbnI') 
AND adj.rslt_dtime > sysdate -30
AND adj.ACT_INST_ID =  (SELECT MAX(ACT_INST_ID) 
                          FROM IBS_AP_ADJ_RSLT adj1
                          WHERE adj1.APP_ID = PROC.PROCESS_INST_ID );
SPOOL OFF;
SET ECHO ON
SET TERMOUT ON
SET FEEDBACK ON

