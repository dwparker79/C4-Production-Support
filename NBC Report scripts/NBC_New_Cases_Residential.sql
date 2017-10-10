SET ECHO OFF
SET TERMOUT OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET LINESIZE 2000
SET TRIMSPOOL ON
COL filename new_value filename
SELECT 'U:\Data\C4_NEW_CASES_RES_'||TO_CHAR(SYSDATE,'MMDDYYYY')||'.TXT' filename FROM DUAL;
SPOOL &&filename
PROMPT APP_ID^FORM_NBR^OFFICE_LOC_CODE^OFFICE_LOC_SUB_CODE^CASE_LOC_CODE^CASE_LOC_SUB_CODE^ALIEN_NBR^LAST_NAME^FIRST_NAME^MIDDLE_NAME^DOB_DT^MR_RECV_DTIME^COB_CODE^R_ADDR_START_DT^R_ADDR_INCAREOF^R_ADDR_BLDG_RM^R_ADDR_STREET_NBR^R_ADDR_STREET_NAME^R_ADDR_CITY^R_ADDR_STATE_CODE^R_ADDR_ZIP_CODE^R_ADDR_PROVINCE^R_ADDR_POSTAL_CODE^R_ADDR_CNTRY_CODE^R_ADDR_UPDATED_DATETIME
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
TO_CHAR(addr.START_DT,'MM/DD/YYYY')||'^'||
addr.INCAREOF||'^'||
addr.BLDG_RM||'^'||
addr.STREET_NBR||'^'||
addr.STREET_NAME||'^'||
addr.CITY||'^'||
addr.STATE_CODE||'^'||
addr.ZIP_CODE||'^'||
addr.PROVINCE||'^'||
addr.POSTAL_CODE||'^'||
addr.CNTRY_CODE||'^'||
TO_CHAR(addr.UPDATED_DATETIME,'MM/DD/YYYY')
FROM 
IBS_AP_APPLICATION apl,
IBS_AP_APPLICANT applic,
IBS_WF_PROCESS_INST proc,
IBS_AP_ADDRESS addr
WHERE 
apl.APP_ID = applic.APP_ID
AND apl.APP_ID = proc.PROCESS_INST_ID
AND apl.APP_ID = addr.APP_ID
-- DWP 2017/06/29 USCISC4-342: Excluding military, military spouse, and BCT cases
AND NVL(apl.MILITARY, 'N') <> 'Y'
AND NVL(apl.MILITARY_SPOUSE, 'N') <> 'Y'
AND NVL(apl.BCT_INDICATOR, 'N') <> 'Y'
AND apl.FORM_NBR in ('N336','N400','N600','N600K')
AND proc.rec_sc_loc_code ='NBC'
AND proc.START_DTIME > SYSDATE -60
AND proc.process_state <> 'Terminated'
AND addr.ADDR_TYPE_IND = 'R'
AND addr.END_DT = TO_DATE('01/01/9999','mm/dd/yyyy');
SPOOL OFF;
SET ECHO ON
SET TERMOUT ON
SET FEEDBACK ON