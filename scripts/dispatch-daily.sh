#!/bin/sh
# Backstop for GitHub's best-effort cron: dispatch the daily-brief workflow once the local publish
# window opens, unless today's edition is already published or a run is in flight.
# Intended to be run hourly (see docs/operations.md); safe to run any number of times.
set -eu

PATH=/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin
REPO=${DAILY_WIRE_REPO:-dcasati/daily-wire}
PAGES=${DAILY_WIRE_PAGES:-https://dcasati.github.io/daily-wire}

hour=$(date +%H)
today=$(date +%F)
# Uses this machine's local time (keep it in the briefing's timezone). Only between 06:00 and 12:59; a later dispatch would no longer be a morning brief.
if [ "$hour" -lt 6 ] || [ "$hour" -gt 12 ]; then
	exit 0
fi

published=$(curl -fsS --max-time 20 "$PAGES/status.json" | sed -n 's/.*"edition": *"\([0-9-]*\)".*/\1/p') || published=
if [ "$published" = "$today" ]; then
	echo "edition $today already published"
	exit 0
fi

# Authenticate with the gh keyring login; the token stays in the environment of this process only.
GH_TOKEN=$(gh auth token --user dcasati)
export GH_TOKEN

active=$(gh run list --repo "$REPO" --workflow daily-brief --limit 5 --json status --jq '[.[] | select(.status != "completed")] | length')
if [ "$active" != "0" ]; then
	echo "run already in progress"
	exit 0
fi

gh workflow run daily-brief --repo "$REPO"
echo "dispatched daily-brief for $today"
