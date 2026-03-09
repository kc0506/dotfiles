#!/usr/bin/env bash
# gpu-ps: list GPU processes with user, time, and memory info
# Usage: gpu-ps [--user username]

target_user=${1#--user }
if [ -z "$target_user" ]; then
    target_user=$USER
fi

nvidia-smi --query-compute-apps=gpu_uuid,pid,process_name,used_memory \
           --format=csv,noheader,nounits |
while IFS=, read -r gpu_uuid pid pname mem; do
    gpu_uuid=$(echo "$gpu_uuid" | xargs)
    pid=$(echo "$pid" | xargs)
    pname=$(echo "$pname" | xargs)
    mem=$(echo "$mem" | xargs)

    # Get GPU index from UUID
    gpu_index=$(nvidia-smi -L | grep -n "$gpu_uuid" | cut -d: -f1 | head -n1)
    gpu_index=$((gpu_index - 1))

    # Process info
    user=$(ps -o user= -p "$pid" 2>/dev/null)
    [ "$user" != "$target_user" ] && continue

    ppid=$(ps -o ppid= -p "$pid" 2>/dev/null)
    start=$(ps -o lstart= -p "$pid" 2>/dev/null | awk '{print $4":"$5}')
    etime=$(ps -o etime= -p "$pid" 2>/dev/null)

    if [ -n "$user" ]; then
        printf "GPU:%-2s PID:%-7s PPID:%-7s USER:%-10s START:%-8s ELAPSED:%-12s MEM:%6s MiB CMD:%s\n" \
            "$gpu_index" "$pid" "$ppid" "$user" "$start" "$etime" "$mem" "$pname"
    fi
done | sort -k1,1n -k6,6nr
