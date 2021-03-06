TRUNCATE TABLE ncs_conv_STpatient_recall_plans

INSERT INTO [ncs_conv_STpatient_recall_plans]
(src_patient_id
,[practice_id]
,[recall_plan_id]
,[seq_nbr]
,[active_plan_ind]
,[plan_start_date]
,[plan_end_date]
,[letter1_sched_date]
,[letter2_sched_date]
,[letter3_sched_date]
,[letter1_sent_date]
,[letter2_sent_date]
,[letter3_sent_date]
,[resource_id]
,[location_id]
,[event_id]
,[create_timestamp]
,[created_by]
,[modify_timestamp]
,[modified_by]
,[expected_return_date]
,[stop_reason]
,[note])
SELECT src_patient_id
,r.[practice_id]
,rp.recall_plan_id
,r.[seq_nbr]
,[active_plan_ind]
,[plan_start_date]  --plan start date should be provided by practice
,[plan_end_date]
,Convert(char(8),DateAdd(d,rpm.first_form_interval * -1),
	DateAdd(d,rpm.event_sched_days,
	Convert(datetime,plan_start_date))),112)  --this must be populated / letter1 sched date
,[letter2_sched_date]
,[letter3_sched_date]
,[letter1_sent_date]
,[letter2_sent_date]
,[letter3_sent_date]
,rx.resource_id
,lx.location_id
,NULL
,GetDate()
,user_id
,GetDate()
,user_id
,Convert(char(8),DateAdd(d,rpm.event_sched_days,
	Convert(datetime,plan_start_date)),112)  --this must be populated / expected return date
,[stop_reason]
,[note]
FROM [ncs_conv_GENappt_recalls] r
INNER JOIN ncs_convXref_RecallPlans rp
ON r.recall_plan = rp.src_plan_id
INNER JOIN ncs_convXref_Resource rx
ON r.src_resource = rx.src_resource_id
INNER JOIN ncs_convXref_Location lx
ON r.src_location = lx.src_location_id
INNER JOIN recall_plan_mstr rpm
ON rp.recall_plan_id = rpm.recall_plan_id
WHERE rp.recall_plan_id IS NOT NULL

/*expected return date and letter1_sched_date need to be filled:
determine from practice what to use for expected return date:
++++++++++++++
pull the date span in the future for the expected return date from the 
recall_plan_mstr.event_sched_days

pull the event_id (if not provided in conversion data) from
recall_plan_mstr.start_event_id

pull the notification lead time (how far ahead of time in days to send
out the recall letter before the expected return date) from
recall_plan_mstr.first_form_interval
*/



SELECT r.* INTO EANM_recalls_not_loaded
FROM [ncs_conv_GENappt_recalls] r
LEFT JOIN ncs_convXref_RecallPlans rp
ON r.recall_plan = rp.src_plan_id
LEFT JOIN ncs_convXref_Resource rx
ON r.src_resource = rx.src_resource_id
LEFT JOIN ncs_convXref_Location lx
ON r.src_location = lx.src_location_id
WHERE rp.recall_plan_id IS NULL
OR rx.resource_id IS NULL
OR lx.location_id IS NULL