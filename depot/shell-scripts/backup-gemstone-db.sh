#!/bin/bash

# exit when any command fails
set -euo pipefail

# Do official GemStone backup. Strange that todeBackup writes all text to stderr instead stdout, we redirect. Errors are catched through exit code.
# This is a GemStone "Smalltalk Backup" which writes all objects condensed. This is not a full snapshot of the dbf file.
todeBackup $1 backup_newest.dbf 2>&1
