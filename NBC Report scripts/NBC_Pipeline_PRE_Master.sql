SET ECHO OFF
SET TERMOUT OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET LINESIZE 600
SET TRIMSPOOL ON
COL filename new_value filename
SELECT 'U:\Data\C4_PIPELINE_PRE_MASTER_'||TO_CHAR(SYSDATE,'MMDDYYYY')||'.TXT' filename FROM DUAL;
SPOOL &&filename
PROMPT APP_ID^FORM_NBR^OFFICE_LOC_CODE^OFFICE_LOC_SUB_CODE^CASE_LOC_CODE^CASE_LOC_SUB_CODE^ALIEN_NBR^LAST_NAME^FIRST_NAME^MIDDLE_NAME^DOB_DT^MR_RECV_DTIME^COB_CODE^CITIZENSHIP_CNTRY_CODE^PERMRES_DT^DISABILITY_FLAG^FORM_N648_ATTACHED_FLAG^ELIGIBILITY_CODE^PROCESS_STATE
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
proc.PROCESS_STATE
FROM 
IBS_AP_APPLICATION apl,
IBS_AP_APPLICANT applic,
IBS_WF_PROCESS_INST proc
WHERE 
apl.APP_ID = applic.APP_ID
AND apl.APP_ID = proc.PROCESS_INST_ID
-- DWP 2017/06/29 USCISC4-342: Excluding military, military spouse, and BCT cases
AND NVL(apl.MILITARY, 'N') <> 'Y'
AND NVL(apl.MILITARY_SPOUSE, 'N') <> 'Y'
AND NVL(apl.BCT_INDICATOR, 'N') <> 'Y'
AND proc.PROCESS_CODE IN ('N336','N400','N600','N600K')
AND proc.rec_sc_loc_code ='NBC'
AND exists (SELECT 1 from ibs_wf_act_inst wf
		WHERE proc.process_inst_id = wf.process_inst_id
		AND wf.act_code in 
		('AFileRtrv', 'Authorized4FP', 
		'BouncedCheck', 'ChkFBI', 
		'DeComplete', 'DeEnter', 
		'FBINameChk', 'FBINameResponse', 
		'LBoxIngestNF', 'MissEvFBI', 
		'MissRqrData', 'PRqtCISVerify', 
		'PVerifyData', 'ResolveNameChk', 
		'ReviewBcdCheck', 'RqrDataATT', 
		'RqtAFileRtrv', 'RqtCISFtr', 
		'RqtCISVerify', 'RqtChkFBI', 
		'RqtSchedFP', 'RqtShpAfile', 
		'SchedDecision', 'SchedFP', 
		'ShpAfile', 'VerifyData', 
		'Wait4FPcard', 'Wait4Payment'));
SPOOL OFF;
SET ECHO ON
SET TERMOUT ON
SET FEEDBACK ON
