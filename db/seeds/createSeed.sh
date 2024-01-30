#!/bin/bash

models=(
Language
Role
Staff

StaffRole

QualysConfig
Team

StaffTeam

Client

#Suppliance
QualysVmClient
QualysWaClient

Contact

ContactRole
ClientContact

Vulnerability

ExploitSource
Exploit
ExploitVulnerability

Project

#Statistic
#Certificate
#CertificateLanguage

Report

#ReportContact

Aggregate
VmScan
WaScan

ReportVmScan
ReportWaScan

VmTarget

ReportTarget

VmOccurrence
WaOccurrence

AggregateVmOccurrence
AggregateWaOccurrence

#History
#Override
Action
Dependency
Comment

#ApplicationRecord
#ReportExport
)

echo '' > db/seeds/seeds.rb

for i in ${models[@]}; do
  if echo "$(cat db/seeds/$i.rb)" >> db/seeds/seeds.rb
    then
      echo "$i done !"
    else
      echo "$i failed ..."
      exit 1
  fi
done