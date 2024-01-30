#!/bin/bash

warnings="$(brakeman -p .. -i brakeman.ignore --no-exit-on-warn --no-exit-on-error | grep 'Security Warnings:' | cut -d ' ' -f3)"
echo $warnings
if [ $warnings -gt 0 ]; then exit 1; else exit 0; fi
