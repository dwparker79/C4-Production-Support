SET ECHO OFF
SET TERMOUT OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET LINESIZE 1000
SET TRIMSPOOL ON
COL filename new_value filename
SELECT 'U:\Data\C4_SUSPENSE_'||TO_CHAR(SYSDATE,'MMDDYYYY')||'.TXT' filename FROM DUAL;
SPOOL &&filename
PROMPT APP_ID^FORM_NBR^OFFICE_LOC_CODE^OFFICE_LOC_SUB_CODE^CASE_LOC_CODE^CASE_LOC_SUB_CODE^ALIEN_NBR^LAST_NAME^FIRST_NAME^MIDDLE_NAME^DOB_DT^MR_RECV_DTIME^COB_CODE^C4_ACTIVITY_CODE^C4_END_CONDITION^C4_DATE_SUSPENDED
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
DECODE(response.response_code,'H','H','I','I',NULL)||'^'||
DECODE(response.response_code,'H','FBINameResponse','I','FBINameResponse',NULL)||'^'||
TO_CHAR(proc.EVENT_DT,'MM/DD/YYYY')
FROM 
IBS_AP_APPLICATION apl,
IBS_AP_APPLICANT applic,
ibs_wf_process_inst proc, 
IBS_AP_FBI_RESPONSE response
WHERE 
apl.APP_ID = applic.APP_ID
AND applic.APP_ID=proc.PROCESS_INST_ID
AND proc.PROCESS_INST_ID= response.APP_ID(+)
-- DWP 2017/06/29 USCISC4-342: Excluding military, military spouse, and BCT cases
AND NVL(apl.MILITARY, 'N') <> 'Y'
AND NVL(apl.MILITARY_SPOUSE, 'N') <> 'Y'
AND NVL(apl.BCT_INDICATOR, 'N') <> 'Y'
and response.response_type_code(+) = 'N'
and response.current_flag(+) = 'Y'  
AND proc.sc_loc_code='NBC'
and proc.process_state='Suspended'
AND proc.EVENT_DT >= TO_DATE ('06/01/2008','MM/DD/YYYY');
SPOOL OFF;
SET ECHO ON
SET TERMOUT ON
SET FEEDBACK ON
