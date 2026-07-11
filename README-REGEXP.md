# Regex Blocking for AI Companions / Adult Content in Pi-hole (Docker)

This setup adds **regex-based blocking rules** to Pi-hole so you can more aggressively block:

- AI “companions”, “girlfriend/boyfriend” bots  
- Pornographic / NSFW / cam / OnlyFans–style domains  

The configuration is designed for **Pi-hole running in a Docker container** and keeps the keyword list in a separate text file so you can edit it easily.

---

## Files

You should have these files in your Pi-hole Docker directory (for example `~/docker/pihole`):

- `generate_companion_regex.sh`  
  Host-side script that adds regex deny rules to the Pi-hole container using `pihole regex`.

- `regex_keywords.txt`  
  Simple text file with one keyword per line. Each keyword becomes a regex of the form `.*keyword.*`.

Example layout:

```text
docker/
└── pihole/
    ├── docker-compose.yml
    ├── generate_companion_regex.sh
    ├── regex_keywords.txt
    ├── etc-pihole/
    └── var-log-pihole/
```

---

## 1. `regex_keywords.txt` format

This file controls which **words** Pi-hole will block wherever they appear inside a domain name.

Create `regex_keywords.txt` next to the script with **one keyword per line**:

```text
# Relationship / companion bots
girlfriend
boyfriend
waifu
soulmate
lover
romance
romantic
cuddle
snuggle
virtualgirlfriend
virtualboyfriend
virtuallover

# Porn / NSFW
porn
porno
sex
nude
deepnude
undress
nsfw
hentai
sext
lewd
spicychat
onlyfans
camgirl
camsite
```

Rules:

- One word per line.
- Blank lines are allowed.
- Lines starting with `#` are treated as comments and ignored.
- Each keyword is turned into a regex like:

  ```text
  .*keyword.*
  ```

So for example, `girlfriend` becomes `.*girlfriend.*` and will match:

- `girlfriend.ai`
- `virtualgirlfriend.app`
- `my-girlfriend-chat.example.com`

---

## 2. Script: `generate_companion_regex.sh`

Place this script in the same directory as `regex_keywords.txt` and make it executable.

```bash
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
  # Skip empty lines and comments
  [[ -z "$kw" ]] && continue
  [[ "$kw" =~ ^# ]] && continue

  REGEX=".*${kw}.*"
  echo "→ Adding regex: ${REGEX}"
  # No -t here: this is non-interactive, so just exec
  docker exec "${CONTAINER_NAME}" pihole regex "${REGEX}"
done < "$KEYWORDS_FILE"

echo
echo "Done. Regex rules added to Pi-hole."
echo "You can review them in the web UI under Group Management → Domains (Regex blacklist)"
echo "or via: docker exec ${CONTAINER_NAME} pihole regex --list"
```

Make it executable:

```bash
chmod +x generate_companion_regex.sh
```

If your container has a different name than `pihole`, update `CONTAINER_NAME` accordingly.

---

## 3. Running the script

From your Pi-hole Docker directory (e.g. `~/docker/pihole`):

```bash
./generate_companion_regex.sh
```

You should see output like:

```text
Adding regex deny rules to Pi-hole container: pihole
Using keywords from: ./regex_keywords.txt

→ Adding regex: .*girlfriend.*
→ Adding regex: .*boyfriend.*
→ Adding regex: .*waifu.*
...
Done. Regex rules added to Pi-hole.
You can review them in the web UI under Group Management → Domains (Regex blacklist)
or via: docker exec pihole pihole regex --list
```

This will add (or re-add) a regex entry in Pi-hole for each keyword in `regex_keywords.txt`.

It is safe to run the script again after updating the keyword list; Pi-hole will handle duplicates gracefully.

---

## 4. Listing and managing active regex rules

To see which regex rules are currently active, use:

```bash
docker exec pihole pihole regex --list
```

This should show IDs and patterns, e.g.:

```text
  0   .*girlfriend.*
  1   .*boyfriend.*
  2   .*waifu.*
  ...
```

If you are inside the container shell, you can run:

```bash
pihole regex --list
```

To get help on regex management:

```bash
docker exec pihole pihole regex -h
```

---

## 5. Removing or adjusting rules

If you accidentally add an unwanted pattern (for example if it over-blocks), you have two options:

1. **Remove via the web UI**

   - Go to the Pi-hole Admin interface.
   - Open **Group Management → Domains**.
   - Filter by **Type: Regex blacklist** (or similar).
   - Delete the entry you no longer want.

2. **Remove via CLI using its ID**

   First, list with:

   ```bash
   docker exec pihole pihole regex --list
   ```

   Note the ID number on the left (e.g. `5`). Then delete it:

   ```bash
   docker exec pihole pihole regex --del 5
   ```

After adjusting, you can update `regex_keywords.txt` so that future runs of `generate_companion_regex.sh` only contain the patterns you want to keep.

---

## 6. Typical workflow for child protection

For protecting children from **porn / NSFW / AI companions**, a reasonable workflow is:

1. Keep `regex_keywords.txt` biased toward **sexual / romantic / cam / OnlyFans** vocabulary you don’t want accessible from your network.
2. Run:

   ```bash
   ./generate_companion_regex.sh
   ```

   whenever you add new words.

3. Combine this with:
   - Your existing `aicompanion.txt` / hosts-style blocklists.
   - External porn/NSFW blocklists in Pi-hole Adlists.
   - Device-level parental controls where possible.

By separating the keywords into `regex_keywords.txt`, you only have to maintain that one file as you discover new terms or domains you want Pi-hole to block network-wide.