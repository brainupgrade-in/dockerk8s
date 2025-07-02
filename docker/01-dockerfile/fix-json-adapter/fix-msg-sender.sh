#!/usr/bin/env bash
HOST=$1; PORT=${2:-5000}; SOH=$'\x01'
TS=$(date -u +"%Y%m%d-%H:%M:%S")
BODY="35=D${SOH}49=SENDER${SOH}56=TARGET${SOH}34=1${SOH}52=${TS}${SOH}11=ORD123${SOH}21=1${SOH}55=IBM${SOH}54=1${SOH}38=100${SOH}40=2${SOH}59=0${SOH}"
LEN=$(echo -n "$BODY" | wc -c)
HEAD="8=FIX.4.4${SOH}9=${LEN}${SOH}"
PRE="${HEAD}${BODY}"
CK=$(printf '%s' "$PRE" | od -An -t u1 | awk '{for(i=1;i<=NF;i++)s+=$i} END{printf "%03d", s%256}')
printf '%s' "${PRE}10=${CK}${SOH}" | nc -w1 "$HOST" "$PORT"

# Usage: ./fix-msg-sender.sh <host> [port]