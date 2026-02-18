#!/bin/bash

# Continuous load generator: PHP app + random walk through Pagila (Ruby) pages
# Press Ctrl+C to stop

PHP_URL="http://localhost:8080"
RUBY_BASE="http://localhost:3000"
PAGILA_BASE="$RUBY_BASE/pagila"
CONCURRENCY=${1:-5}

# Max pages per Pagila list (20 items per page): films=1000, actors=200, categories=16, customers=599
PAGILA_FILMS_MAX_PAGE=50
PAGILA_ACTORS_MAX_PAGE=10
PAGILA_CATEGORIES_MAX_PAGE=1
PAGILA_CUSTOMERS_MAX_PAGE=30

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
echo "PHP: $PHP_URL (fixed)"
echo "Ruby/Pagila: random walk over $PAGILA_BASE (index, films, actors, categories, customers)"
echo "Concurrency: $CONCURRENCY workers per app"
echo "Delay between requests: random 0-3s"
echo "Press Ctrl+C to stop"
echo ""

# Check if apps are reachable
if ! curl -s --max-time 2 "$PHP_URL" > /dev/null; then
    echo "Error: PHP app not reachable at $PHP_URL"
    exit 1
fi

if ! curl -s --max-time 2 "$RUBY_BASE" > /dev/null; then
    echo "Error: Ruby app not reachable at $RUBY_BASE"
    exit 1
fi

echo "Starting continuous load..."
echo ""

# Random delay 0–3s
random_delay() {
    awk 'BEGIN{srand(); print rand() * 3}'
}

# Random integer in [1, max] (inclusive)
random_page() {
    local max=$1
    awk -v max="$max" 'BEGIN{srand(); print int(1 + rand() * max)}'
}

# Pick a random Pagila URL: index or one of the list pages with random page number
random_pagila_url() {
    case $(awk 'BEGIN{srand(); print int(rand()*5)}') in
        0) echo "${PAGILA_BASE}" ;;
        1) echo "${PAGILA_BASE}/films?page=$(random_page $PAGILA_FILMS_MAX_PAGE)" ;;
        2) echo "${PAGILA_BASE}/actors?page=$(random_page $PAGILA_ACTORS_MAX_PAGE)" ;;
        3) echo "${PAGILA_BASE}/categories?page=$(random_page $PAGILA_CATEGORIES_MAX_PAGE)" ;;
        4) echo "${PAGILA_BASE}/customers?page=$(random_page $PAGILA_CUSTOMERS_MAX_PAGE)" ;;
    esac
}

# PHP: hit home repeatedly
send_continuous_php() {
    while $RUNNING; do
        curl -s -o /dev/null "$PHP_URL"
        sleep "$(random_delay)"
    done
}

# Ruby: random walk over Pagila pages
send_continuous_pagila() {
    while $RUNNING; do
        curl -s -o /dev/null "$(random_pagila_url)"
        sleep "$(random_delay)"
    done
}

# Start workers for PHP app
for ((c=1; c<=CONCURRENCY; c++)); do
    send_continuous_php &
done

# Start workers for Ruby/Pagila random walk
for ((c=1; c<=CONCURRENCY; c++)); do
    send_continuous_pagila &
done

# Monitor and display stats
while $RUNNING; do
    sleep 5
    TOTAL_REQUESTS=$((TOTAL_REQUESTS + CONCURRENCY * 2 * 5 / 1))
    echo "[$(date '+%H:%M:%S')] Approximate requests sent: ~$TOTAL_REQUESTS"
done
