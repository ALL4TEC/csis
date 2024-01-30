#!/bin/bash

models=(
Action
AggregateVmOccurrence
AggregateWaOccurrence
Aggregate
#ApplicationRecord
#CertificateLanguage
#Certificate
ClientContact
Client
Comment
ContactRole
Contact
Dependency
ExploitSource
ExploitVulnerability
Exploit
#History
Language
#Override
Project
QualysConfig
QualysVmClient
QualysWaClient
ReportContact
#ReportExport
ReportTarget
ReportVmScan
ReportWaScan
Report
Role
StaffRole
StaffTeam
Staff
#Statistic
#Suppliance
Team
VmOccurrence
VmScan
VmTarget
Vulnerability
WaOccurrence
WaScan
)

for i in ${models[@]}; do
  if rails db:seed:dump EXCLUDE=created_at,updated_at MODELS=$i FILE=db/seeds/$i.rb > /dev/null 2>&1
    then
      echo "$i done !"
    else
      echo "$i failed ..."
  fi
done