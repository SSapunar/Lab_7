# Lab 7 — VetClinic: Action Text & Active Storage
## Setup

```bash
bundle install
bin/rails db:setup
bin/rails server
```

Then open http://localhost:3000.

## Notes

Action Text sanitizes all rich text input by default. Tested by pasting `<script>alert(1)</script>` into the clinical notes editor — the script tag is stripped on save and no alert fires on the show page.