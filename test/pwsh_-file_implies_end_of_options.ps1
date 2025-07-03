#!/usr/bin/env pwsh
# -*- coding: utf-8, tab-width: 2 -*-
#
# Demonstrate that `-File` implies end of pwsh options:

Write-Host "$($args | ConvertTo-Json -Compress)"

# Example:
# pwsh -File pwsh_-file_implies_end_of_options.ps1 -NoExit -File nope.ps1 foo
#   -> ["-NoExit","-File","nope.ps1","foo"]
