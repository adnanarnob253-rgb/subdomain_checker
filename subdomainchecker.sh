#!/bin/bash
echo "[*]Sami's subdomain checker"

set -euo pipefail

usage() {
    echo "Usage: $0 -s <subdomains_file>"
    echo "  -s    Path to a text file containing subdomains (one per line)"
    exit 1
}

SUBDOMAINS_FILE=""

# Parse flags
while getopts ":s:" opt; do
  case $opt in
    s)
      SUBDOMAINS_FILE="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      usage
      ;;
  esac
done

if [[ -z "${SUBDOMAINS_FILE}" ]]; then
    echo "Error: You must provide a subdomains file with -s."
    usage
fi

if [[ ! -f "${SUBDOMAINS_FILE}" ]]; then
    echo "Error: File not found: ${SUBDOMAINS_FILE}"
    exit 1
fi

echo "[*] Sami's Subdomain Checker "
echo "[*] Checking which subdomains are alive..."
echo ""

# Read subdomains from file, ignoring empty lines and trimming whitespace
while IFS= read -r sub || [[ -n "$sub" ]]; do
    # Trim leading/trailing whitespace
    sub="$(echo "$sub" | xargs)"
    # Skip empty lines or lines that start with a comment '#'
    [[ -z "$sub" || "$sub" =~ ^# ]] && continue

    echo -n "Testing $sub... "
    status=$(curl -s -o /dev/null -w "%{http_code}" "https://$sub" --max-time 5)
    if [[ "$status" == "200" || "$status" == "301" || "$status" == "302" ]]; then
        echo "✓ ALIVE ($status)"
    else
        echo "✗ Dead or Protected ($status)"
    fi
done < "$SUBDOMAINS_FILE"

echo ""
echo "[*] Scan complete !"
