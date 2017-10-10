SET ECHO OFF
SET TERMOUT OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET LINESIZE 600
SET TRIMSPOOL ON
COL filename new_value filename
SELECT 'U:\Data\C4_PIPELINE_PRE_WF_DETAIL_'||TO_CHAR(SYSDATE,'MMDDYYYY')||'.TXT' filename FROM DUAL;
SPOOL &&filename
PROMPT APP_ID^ACT_CODE^ACT_STATE^STATE_DTIME^EXPCT_START_DTIME^EXPCT_EXPIR_DTIME
SELECT
proc.PROCESS_INST_ID||'^'||
wf.ACT_CODE||'^'||
wf.ACT_STATE||'^'||
TO_CHAR(wf.STATE_DTIME,'MM/DD/YYYY')||'^'||
TO_CHAR(wf.EXPCT_START_DTIME,'MM/DD/YYYY')||'^'||
TO_CHAR(wf.EXPCT_EXPIR_DTIME,'MM/DD/YYYY')
FROM 
IBS_AP_APPLICATION apl,
IBS_WF_PROCESS_INST proc,
IBS_WF_ACT_INST wf
WHERE 
wf.PROCESS_INST_ID = proc.PROCESS_INST_ID
AND apl.APP_ID = proc.PROCESS_INST_ID (+)
-- DWP 2017/06/29 USCISC4-342: Excluding military, military spouse, and BCT cases
AND NVL(apl.MILITARY, 'N') <> 'Y'
AND NVL(apl.MILITARY_SPOUSE, 'N') <> 'Y'
AND NVL(apl.BCT_INDICATOR, 'N') <> 'Y'
AND proc.PROCESS_CODE IN ('N336','N400','N600','N600K')
AND proc.rec_sc_loc_code ='NBC'
AND exists (SELECT 1 from ibs_wf_act_inst wflow
		WHERE proc.process_inst_id = wflow.process_inst_id
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
