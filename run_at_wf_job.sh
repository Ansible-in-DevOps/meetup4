#!/bin/bash

# Input variables
TOWERURL=$1;
TOWERLOGIN=$2;
TOWERPASSWORD=$3;

# Ansible Tower Credentials
ATCRED="$TOWERLOGIN:$TOWERPASSWORD";

# Ansible Tower Job Template ID
ATJTID=37;

echo "--";
date;

echo "Staring Ansible Tower job template ...";
JOBID=`curl -s -k -X POST -u $ATCRED https://$TOWERURL/api/v2/workflow_job_templates/$ATJTID/launch/ | jq -r '.id'`;
echo "Job id: $JOBID";

JOBSTATUS=`curl -s -k -X GET -u $ATCRED https://$TOWERURL/api/v2/workflow_jobs/$JOBID/ | jq -r '.status'`;
while [ $JOBSTATUS == "waiting" ] || [ $JOBSTATUS == "running" ] || [ $JOBSTATUS == "null" ];
 do
  sleep 5;
  JOBSTATUS=`curl -s -k -X GET -u $ATCRED https://$TOWERURL/api/v2/workflow_jobs/$JOBID/ | jq -r '.status'`;
 done

function jobOutput {
 echo "Job status: $JOBSTATUS";
 echo "--";
 echo "Job output:";
 echo "";
 curl -s -k -X GET -u $ATCRED https://$TOWERURL/api/v2/workflow_jobs/$JOBID/stdout/?format=txt;
}

if [ $JOBSTATUS == "successful" ]
then
 jobOutput;
 echo "--";
 date;
 exit 0;
else
 jobOutput;
 echo "--";
 date;
 exit 1;
fi

# end.

