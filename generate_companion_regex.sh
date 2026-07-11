#!/usr/bin/env bash
# generate_companion_regex.sh
#
# Add regex deny rules to a Pi-hole instance running in Docker
# to block AI "companion" / NSFW-style domains by keyword.
#
# Run this on the DOCKER HOST, not inside the container.

# Name of your Pi-hole container (from `docker ps`)
CONTAINER_NAME="pihole"

# Path to the keyword list file (one keyword per line)
KEYWORDS_FILE="./regex_keywords.txt"

if [[ ! -f "$KEYWORDS_FILE" ]]; then
  echo "ERROR: Keywords file not found: $KEYWORDS_FILE"
  echo "Create it with one keyword per line, e.g.:"
  echo "  girlfriend"
  echo "  porn"
  echo "  nsfw"
  exit 1
fi

echo "Adding regex deny rules to Pi-hole container: ${CONTAINER_NAME}"
echo "Using keywords from: ${KEYWORDS_FILE}"
echo

# Read keywords line-by-line
while IFS= read -r kw; do
  [[ -z "$kw" ]] && continue
  [[ "$kw" =~ ^# ]] && continue

  REGEX=".*${kw}.*"
  echo "→ Adding regex: ${REGEX}"
  docker exec pihole pihole regex "${REGEX}"
done < "$KEYWORDS_FILE"

echo
echo "Done. Regex rules added to Pi-hole."
echo "You can review them in the web UI under Group Management → Domains (type: Regex blacklist)."

