#!/bin/bash

# Continuous load generator for PHP and Ruby apps
# Press Ctrl+C to stop

PHP_URL="http://localhost:8080"
RUBY_URL="http://localhost:4567"
CONCURRENCY=${1:-5}

TOTAL_REQUESTS=0
RUNNING=true

# Handle Ctrl+C gracefully
cleanup() {
    RUNNING=false
    echo ""
    echo "Stopping load generator..."
    kill $(jobs -p) 2>/dev/null
    wait 2>/dev/null
    echo "Total requests sent: $TOTAL_REQUESTS"
    exit 0
}

trap cleanup INT TERM

echo "Continuous Load Generator"
echo "========================="
echo "Concurrency: $CONCURRENCY workers per app"
echo "Delay between requests: random 0-3s"
echo "Press Ctrl+C to stop"
echo ""

# Check if apps are reachable
if ! curl -s --max-time 2 "$PHP_URL" > /dev/null; then
    echo "Error: PHP app not reachable at $PHP_URL"
    exit 1
fi

if ! curl -s --max-time 2 "$RUBY_URL" > /dev/null; then
    echo "Error: Ruby app not reachable at $RUBY_URL"
    exit 1
fi

echo "Starting continuous load..."
echo ""

# Function to generate random delay between 0 and 1 second
random_delay() {
    awk 'BEGIN{srand(); print rand() * 3}'
}

# Function to continuously send requests
send_continuous() {
    local url=$1
    local name=$2
    
    while $RUNNING; do
        curl -s -o /dev/null "$url"
        sleep "$(random_delay)"
    done
}

# Start workers for PHP app
for ((c=1; c<=CONCURRENCY; c++)); do
    send_continuous "$PHP_URL" "PHP-$c" &
done

# Start workers for Ruby app
for ((c=1; c<=CONCURRENCY; c++)); do
    send_continuous "$RUBY_URL" "Ruby-$c" &
done

# Monitor and display stats
while $RUNNING; do
    sleep 5
    # Count approximate requests (workers * time / delay)
    TOTAL_REQUESTS=$((TOTAL_REQUESTS + CONCURRENCY * 2 * 5 / 1))
    echo "[$(date '+%H:%M:%S')] Approximate requests sent: ~$TOTAL_REQUESTS"
done
