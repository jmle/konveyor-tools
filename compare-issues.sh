#!/bin/bash

# Stop execution on error
set -o pipefail
#set -x

windup_report_dir="${1}"
kantra_report_dir="${2}"

# Check if files exist (do not print)
stat ${windup_report_dir} >null 2>null
stat ${kantra_report_dir} >null 2>null

windup_issues_file=${windup_report_dir}/api/issues.json
kantra_issues_file=${kantra_report_dir}/static-report/output.js

cat ${windup_issues_file} | jq '.[0].issues | to_entries[] | .value | .[].ruleId' | sort | uniq > .windup-issues.tmp
cat ${kantra_issues_file} | sed 's/^window\["apps"\] = //g' | jq '.[] | .rulesets | .[] | .violations' | sed 's/^null$//g' | jq 'to_entries[].key' | sort | uniq > .kantra-issues.tmp

diff=$(diff .windup-issues.tmp .kantra-issues.tmp)
echo "Missing from Kantra report:"
echo "${diff}" | grep '<' | sed 's/^< "//g' | sed 's/"$//g'

rm -rf .windup-issues.tmp .kantra-issues.tmp