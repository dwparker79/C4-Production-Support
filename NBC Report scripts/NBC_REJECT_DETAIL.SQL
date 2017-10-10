SET ECHO OFF
SET TERMOUT OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET LINESIZE 2000
SET TRIMSPOOL ON
COL filename new_value filename
SELECT 'U:\Data\C4_REJECT_DETAIL_'||TO_CHAR(SYSDATE,'MMDDYYYY')||'.TXT' filename FROM DUAL;
SPOOL &&filename
PROMPT APP_ID^REJECT_REASON
SELECT
proc.PROCESS_INST_ID||'^'||
b.END_COND_CODE
FROM 
IBS_AP_APPLICATION apl,
IBS_WF_ACT_INST_STATE a, 
IBS_WF_END_COND_INST b, 
IBS_WF_PROCESS_INST proc
WHERE 
proc.PROCESS_INST_ID = a.PROCESS_INST_ID
and a.ACT_INST_ID = b.ACT_INST_ID
AND apl.APP_ID = a.PROCESS_INST_ID (+)
-- DWP 2017/06/29 USCISC4-342: Excluding military, military spouse, and BCT cases
AND NVL(apl.MILITARY, 'N') <> 'Y'
AND NVL(apl.MILITARY_SPOUSE, 'N') <> 'Y'
AND NVL(apl.BCT_INDICATOR, 'N') <> 'Y'
and proc.PROCESS_CODE = 'LOCKBOX'
and proc.PROCESS_STATE = 'Terminated'
and proc.PROCESS_INST_ID like 'NBC*%'
and proc.START_DTIME > sysdate -30
and a.ACT_STATE = 'Completed'
and a.ACT_CODE = 'Lockbox'
and EXISTS (select 1 from IBS_WF_ACT_INST_STATE c
                where a.PROCESS_INST_ID = c.PROCESS_INST_ID
                and b.END_COND_CODE in ('BOE2DIssues','IneligDuetoAge',
                'CheckNotCurrent','CheckNotInUS','CheckNotSigned',
                'ExpFormRev','FeeIssue','MissBOE','MissPage',
                'MissRequiredData','MissSign','MultipleBOE',
                'NotInBlueOrBlack','OneCheckBadApps','ResidencyIssues',
                'Under18Yrs','WrongMethodOfPay','WrongPayToOrder'));
SPOOL OFF;
SET ECHO ON
SET TERMOUT ON
SET FEEDBACK ON

