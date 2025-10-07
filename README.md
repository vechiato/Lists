# AI Companion List (Pi-hole)

A Pi-hole–ready blocklist that targets AI companion, roleplay, and chatbot websites (including NSFW platforms and discovery portals). Designed for network-level filtering via Pi-hole.

## What this is
- A plain-text hosts-format list for Pi-hole (`0.0.0.0 domain` per line).
- Alphabetically sorted and deduplicated.
- Scope: AI companionship, romance/roleplay, sexting bots, multi-bot portals that surface companions, and related directories.

## How to use with Pi-hole
1. Open Pi-hole Admin → Group Management → Adlists.
2. Add the raw URL of `aicompanion.txt` from this repository.
3. Save, then run:
   - Tools → Update Gravity (or `pihole -g` via SSH).
4. (Optional) Assign this adlist to specific Pi-hole groups to control which clients are affected.

### Tips
- Pi-hole matches exact domains; add `www.` or notable subdomains as separate entries if needed.
- If a domain resolves to parked or defunct content, consider removing it in a PR.

## Updating
- The header in `aicompanion.txt` includes the last update date (YYYYMMDD).
- After pulling changes, run Update Gravity again to apply new entries.

## Contributing
- Format: `0.0.0.0 example.com` (no protocols, no paths, no wildcards).
- Keep alphabetical order and avoid duplicates.
- Include a brief rationale in your PR (e.g., “Companion app,” “NSFW roleplay,” “Discovery portal”).
- Update the date in the header.

## Issues
Use GitHub Issues to report:
- False positives (legitimate sites being blocked).
- Defunct domains and redirects.
- Suggestions for clearer scope or categories.

## Disclaimer
Provided “as is.” Domains may change over time; review periodically. Network environments vary, and maintainers aren’t responsible for unintended blocking effects.

## License
MIT License
