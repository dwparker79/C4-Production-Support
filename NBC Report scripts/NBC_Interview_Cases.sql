SET ECHO OFF
SET TERMOUT OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET LINESIZE 2000
SET TRIMSPOOL ON
COL filename new_value filename
SELECT 'U:\Data\C4_INTERVIEW_'||TO_CHAR(SYSDATE,'MMDDYYYY')||'.TXT' filename FROM DUAL;
SPOOL &&filename
PROMPT APP_ID^FORM_NBR^OFFICE_LOC_CODE^OFFICE_LOC_SUB_CODE^CASE_LOC_CODE^CASE_LOC_SUB_CODE^ALIEN_NBR^LAST_NAME^FIRST_NAME^MIDDLE_NAME^DOB_DT^MR_RECV_DTIME^COB_CODE^CITIZENSHIP_CNTRY_CODE^PERMRES_DT^DISABILITY_FLAG^FORM_N648_ATTACHED_FLAG^ELIGIBILITY_CODE^SCHEDULED_ON_DATE^INTERVIEW_DATE^INTERVIEW_TIME^EXAMINER_SECT_ID_ROOM^INTERVIEW_READY_DATE^SRVC_TYPE_CODE
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
TO_CHAR(schist.CREATE_DT,'MM/DD/YYYY')||'^'||
TO_CHAR(sc.INTV_DT,'MM/DD/YYYY')||'^'||
TO_CHAR(sc.INTV_START_TIME,'HH:MI PM')||'^'||
DECODE(sc.ADJ_NBR||'/'||sc.RM_SECT_ID||'/'||sc.INTV_RM_ID,'//',
       NULL,sc.ADJ_NBR||'/'||sc.RM_SECT_ID||'/'||sc.INTV_RM_ID)||'^'||
TO_CHAR(wfs.STATE_DTIME,'MM/DD/YYYY')||'^'||
SC.SRVC_TYPE_CODE
FROM 
IBS_AP_APPLICATION apl,
IBS_AP_APPLICANT applic,
IBS_WF_PROCESS_INST proc,
IBS_WF_ACT_INST_STATE wfs,
IBS_SC_I_SECT_APP_APPT sc,
IBS_SC_HISTORY schist,
IBS_WF_ACT_INST wf
WHERE 
apl.APP_ID = applic.APP_ID
AND apl.APP_ID = proc.PROCESS_INST_ID 
AND apl.APP_ID = wfs.PROCESS_INST_ID 
AND apl.APP_ID = sc.APP_ID
AND apl.APP_ID = schist.APP_ID (+)
AND apl.APP_ID = wf.PROCESS_INST_ID 
-- DWP 2017/06/29 USCISC4-342: Excluding military, military spouse, and BCT cases
AND NVL(apl.MILITARY, 'N') <> 'Y'
AND NVL(apl.MILITARY_SPOUSE, 'N') <> 'Y'
AND NVL(apl.BCT_INDICATOR, 'N') <> 'Y'
AND proc.rec_sc_loc_code ='NBC'
AND proc.process_code = 'N400'
AND proc.process_state <> 'Terminated'
AND wfs.act_code ='MergeSched' 
AND wfs.act_state ='Completed'
AND wf.ACT_CODE IN ('Interview','RqtIntvw','SchedIntvw') 
AND schist.CREATE_DT = (SELECT MAX(sch.CREATE_DT)
			FROM IBS_SC_HISTORY sch
			WHERE sch.APP_ID = apl.APP_ID)
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
''||'^'||
''||'^'||
''||'^'||
''||'^'||
TO_CHAR(wfs.STATE_DTIME,'MM/DD/YYYY')||'^'||
''
FROM 
IBS_AP_APPLICATION apl,
IBS_AP_APPLICANT applic,
IBS_WF_PROCESS_INST proc,
IBS_WF_ACT_INST_STATE wfs,
IBS_WF_ACT_INST wf
WHERE 
apl.APP_ID = applic.APP_ID
AND apl.APP_ID = proc.PROCESS_INST_ID 
AND apl.APP_ID = wfs.PROCESS_INST_ID 
AND apl.APP_ID = wf.PROCESS_INST_ID 
-- DWP 2017/06/29 USCISC4-342: Excluding military, military spouse, and BCT cases
AND NVL(apl.MILITARY, 'N') <> 'Y'
AND NVL(apl.MILITARY_SPOUSE, 'N') <> 'Y'
AND NVL(apl.BCT_INDICATOR, 'N') <> 'Y'
AND proc.rec_sc_loc_code ='NBC'
AND proc.process_code = 'N400'
AND proc.process_state <> 'Terminated'
AND wfs.act_code ='MergeSched' 
AND wfs.act_state ='Completed'
AND wf.ACT_CODE in ('RqtIntvw','SchedIntvw','IntvDecision')
AND not exists (select 1 from ibs_sc_history hist
	where apl.app_id = hist.app_id
	and hist.srvc_type_code in ('IN400','REN400','QAN400'));
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
TO_CHAR(schist.CREATE_DT,'MM/DD/YYYY')||'^'||
TO_CHAR(sc.INTV_DT,'MM/DD/YYYY')||'^'||
TO_CHAR(sc.INTV_START_TIME,'HH:MI PM')||'^'||
DECODE(sc.ADJ_NBR||'/'||sc.RM_SECT_ID||'/'||sc.INTV_RM_ID,'//',
       NULL,sc.ADJ_NBR||'/'||sc.RM_SECT_ID||'/'||sc.INTV_RM_ID)||'^'||
TO_CHAR(wfs.STATE_DTIME,'MM/DD/YYYY')||'^'||
SC.SRVC_TYPE_CODE
FROM 
IBS_AP_APPLICATION apl,
IBS_AP_APPLICANT applic,
IBS_WF_PROCESS_INST proc,
IBS_WF_ACT_INST_STATE wfs,
IBS_SC_I_SECT_APP_APPT sc,
IBS_SC_HISTORY schist,
IBS_WF_ACT_INST wf
WHERE 
apl.APP_ID = applic.APP_ID
AND apl.APP_ID = proc.PROCESS_INST_ID 
AND apl.APP_ID = wfs.PROCESS_INST_ID 
AND apl.APP_ID = sc.APP_ID (+)
AND apl.APP_ID = schist.APP_ID (+)
AND apl.APP_ID = wf.PROCESS_INST_ID 
-- DWP 2017/06/29 USCISC4-342: Excluding military, military spouse, and BCT cases
AND NVL(apl.MILITARY, 'N') <> 'Y'
AND NVL(apl.MILITARY_SPOUSE, 'N') <> 'Y'
AND NVL(apl.BCT_INDICATOR, 'N') <> 'Y'
AND proc.process_code IN ('N600', 'N600K')
AND proc.process_state IN ('Active','Suspended','Running')
AND wfs.act_code = 'ShpAfile'
AND wfs.act_state = 'Inactive'
AND wfs.state_dtime > SYSDATE - 30
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
TO_CHAR(schist.CREATE_DT,'MM/DD/YYYY')||'^'||
TO_CHAR(sc.INTV_DT,'MM/DD/YYYY')||'^'||
TO_CHAR(sc.INTV_START_TIME,'HH:MI PM')||'^'||
DECODE(sc.ADJ_NBR||'/'||sc.RM_SECT_ID||'/'||sc.INTV_RM_ID,'//',
       NULL,sc.ADJ_NBR||'/'||sc.RM_SECT_ID||'/'||sc.INTV_RM_ID)||'^'||
TO_CHAR(wfs.STATE_DTIME,'MM/DD/YYYY')||'^'||
SC.SRVC_TYPE_CODE
FROM 
IBS_AP_APPLICATION apl,
IBS_AP_APPLICANT applic,
IBS_WF_PROCESS_INST proc,
IBS_WF_ACT_INST_STATE wfs,
IBS_SC_I_SECT_APP_APPT sc,
IBS_SC_HISTORY schist,
IBS_WF_ACT_INST wf
WHERE 
apl.APP_ID = applic.APP_ID
AND apl.APP_ID = proc.PROCESS_INST_ID 
AND apl.APP_ID = wfs.PROCESS_INST_ID 
AND apl.APP_ID = sc.APP_ID (+)
AND apl.APP_ID = schist.APP_ID (+)
AND apl.APP_ID = wf.PROCESS_INST_ID 
-- DWP 2017/06/29 USCISC4-342: Excluding military, military spouse, and BCT cases
AND NVL(apl.MILITARY, 'N') <> 'Y'
AND NVL(apl.MILITARY_SPOUSE, 'N') <> 'Y'
AND NVL(apl.BCT_INDICATOR, 'N') <> 'Y'
AND proc.process_code = 'N336'
AND proc.process_state IN ('Active','Suspended','Running')
AND wfs.act_code = 'IntvwDecision'
AND wfs.act_state = 'Inactive'
AND wfs.state_dtime = (SELECT MIN(wfs1.state_dtime) 
                         FROM ibs_wf_act_inst_state wfs1
                	 WHERE wfs1.process_inst_id = proc.process_inst_id
                      	   AND wfs1.act_code = 'IntvwDecision'
                      	   AND wfs1.act_state = 'Inactive'
                      	   AND wfs1.state_dtime >SYSDATE - 60);
SPOOL OFF;
SET ECHO ON
SET TERMOUT ON
SET FEEDBACK ON
