# Lab 7 — VetClinic: Action Text & Active Storage

## Setup

```bash
bundle install
bin/rails db:setup
bin/rails server
```

Then open http://localhost:3000.

## System Dependencies

Active Storage image variants require **libvips** to be installed on your machine. Rails 8 uses libvips as its default image processor.

Install it before running the app:

- **macOS (Homebrew):** `brew install vips`
- **Arch Linux:** `sudo pacman -S libvips`
- **Debian / Ubuntu:** `sudo apt install libvips`

## Sanitization Check

Action Text sanitizes all rich text input by default. Tested by pasting `<script>alert(1)</script>` into the clinical notes editor — the script tag is stripped on save and no alert fires on the show page.
