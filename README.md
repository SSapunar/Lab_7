# Lab 7 — VetClinic: Action Text & Active Storage

## Objective

In this lab, you will enrich the VetClinic application with two Rails frameworks built on top of Active Record:

- **Active Storage**, to attach a profile photo to each Pet and display it across the application.
- **Action Text**, to let veterinarians write rich, formatted clinical notes for each Treatment (headings, bold/italic, lists, links).

Action Text was covered in class — this lab will only sketch what to do with it. Active Storage was only briefly mentioned, so the Active Storage sections walk you through the framework in more detail.

By the end of this lab, owners will recognize their pets at a glance from a thumbnail in the index, and treatments will carry properly formatted clinical notes instead of plain-text strings.

## Reference Material

Both frameworks are documented in the official Rails guides. You should keep these open in a tab as you work:

- **Active Storage Overview** — <https://guides.rubyonrails.org/active_storage_overview.html>
- **Action Text Overview** — <https://guides.rubyonrails.org/action_text_overview.html>
- **Form Helpers — Uploading Files** — <https://guides.rubyonrails.org/form_helpers.html#uploading-files>

Specific subsections of each guide are linked from the relevant instruction below.

## Setup

In this lab you will continue working on the VetClinic application you built in Lab 6, but you must submit it in a **new repository**. Your Lab 6 repository will not be reviewed for this lab.

1. **Create a new, empty repository** on GitHub (no README, no .gitignore, no license — completely empty). Make sure it is **public** so the teaching assistant can review it.

2. In your local `vet_clinic` project from Lab 6, add the new repository as a remote and push your code:

```bash
cd vet_clinic
git remote add lab7 <your-new-repo-url>
git push -u lab7 main
```

3. Verify on GitHub that your code is now in the new repository.

4. From now on, push your Lab 7 work to this new remote:

```bash
git push lab7 main
```

5. **Submit the link to your new repository on Canvas.**

## Part A — Active Storage (guided)

### A.1. What Active Storage Is

Active Storage is the Rails framework for handling file uploads. It separates **the file metadata** (filename, content type, byte size, checksum) from **the file bytes** themselves.

- The metadata lives in two database tables that Rails creates for you: `active_storage_blobs` (one row per uploaded file) and `active_storage_attachments` (a polymorphic join row that links a blob to a record in your domain — e.g., a particular Pet).
- The bytes live in a configurable **service**: local disk in development and tests, and typically a cloud bucket (S3, GCS, Azure) in production. The service is configured in `config/storage.yml` and selected per environment in `config/environments/*.rb`. For this lab, the default `local` service is fine.

This separation is what lets you, for example, replace a Pet's photo without touching the Pet row itself: a new blob is created, the attachment row is repointed at it, and the old blob can be discarded later. It's also why you must run a migration to add the Active Storage tables before using the framework.

Read the *What is Active Storage?* and *Setup* sections of the guide before continuing — they are short and the rest of this part will make much more sense afterwards:

- <https://guides.rubyonrails.org/active_storage_overview.html#what-is-active-storage-questionmark>
- <https://guides.rubyonrails.org/active_storage_overview.html#setup>

### A.2. Install Active Storage

Run the installer. It generates a migration that creates the three Active Storage tables (`active_storage_blobs`, `active_storage_attachments`, and `active_storage_variant_records`) and then migrate your database:

```bash
bin/rails active_storage:install
bin/rails db:migrate
```

Active Storage variants (resized versions of an image) are produced on the fly by an image processor on your machine. Rails 8 uses **libvips** by default. Install it if you do not already have it:

- Arch: `sudo pacman -S libvips`
- macOS (Homebrew): `brew install vips`
- Debian/Ubuntu: `sudo apt install libvips`

Confirm that the `image_processing` gem is in your `Gemfile` (it should already be there from `rails new`). If not, add it and `bundle install`.

### A.3. Attach a Photo to Pet

Declare on the `Pet` model that each pet may have **at most one** attached photo. Active Storage exposes two macros for this kind of declaration: one for "exactly zero or one attached file per record", another for "any number of attached files per record". Pick the appropriate one — read the *Attaching Files to Records* section of the guide if you are unsure:

<https://guides.rubyonrails.org/active_storage_overview.html#attaching-files-to-records>

The attachment must be **optional**: a pet without a photo should still save successfully.

### A.4. Validate the Photo

When a photo *is* attached, you want it to be a real, reasonably-sized image — not, say, a 2 GB ZIP file that someone renamed to `dog.png`.

Active Storage does not provide a `validates :photo, content_type: ..., size: ...` macro out of the box. Instead, you write a regular `validate :method_name` and inspect the attachment yourself.

The relevant section of the guide is *Validating Attachments*: <https://guides.rubyonrails.org/active_storage_overview.html#validating-attachments>.

Things you should know to write this validation:

- `pet.photo.attached?` returns whether anything is currently attached. Your validation should return early when nothing is attached (the photo is optional).
- An attached blob exposes `content_type` (a MIME type string like `"image/png"`) and `byte_size` (an integer). These are available *before* the upload completes and reach the service, because Rails reads them when the file is received.
- `errors.add(:photo, "...")` adds a validation error scoped to the `:photo` attribute, which is what the Lab 6 `_error_messages` partial knows how to display.

Implement two checks inside your validation:

- The content type, when present, must be one of `image/jpeg`, `image/png`, or `image/webp`.
- The byte size, when present, must be at most 5 megabytes (`5.megabytes`).

### A.5. Photo in the Pet Form

Update the Pet `_form.html.erb` partial so users can upload a photo. The relevant Rails guide section is *Form Helpers — Uploading Files*: <https://guides.rubyonrails.org/form_helpers.html#uploading-files>.

- Add a Bootstrap-styled file input bound to the `:photo` attribute. Hint: the form helper for file uploads is `file_field`. Style with `form-control` and wrap in the standard `mb-3` container.
- On the **edit** form (i.e., when the pet record is persisted and already has a photo attached), display the current photo above the file input as a small thumbnail (around 100 px wide), with a label like "Current photo". You can use the `image_tag` helper directly with the attachment — Rails knows how to generate a signed URL for it (see *Linking to Files*: <https://guides.rubyonrails.org/active_storage_overview.html#linking-to-files>).
- Validation errors on `:photo` must be surfaced through the `_error_messages` partial you wrote in Lab 6. You should not need any additional plumbing for this — the partial already iterates over `object.errors.full_messages`.
- Important: for the file upload to actually be sent, `form_with` must produce a `multipart/form-data` form. `form_with(model: ...)` does this automatically as soon as it sees a file field, but if you wrote your own form tag manually you would need to pass `multipart: true`. Verify in the rendered HTML (right-click → View Page Source) that the `<form>` tag has `enctype="multipart/form-data"`.

### A.6. Photo on the Pet Show Page

On the Pet **show** page:

- If the pet has a photo attached, render it at a comfortable size (around 300 px wide) with Bootstrap classes such as `img-fluid rounded`.
- If no photo is attached, show a neutral placeholder (a Bootstrap-styled `<div>` saying "No photo available" is fine, or a generic silhouette icon — your choice, but be consistent).

### A.7. Thumbnails on the Pet Index

The Pet **index** page lists every pet in the system. Loading the original full-resolution photo for each row would be wasteful — a single page could pull megabytes of image data even though each row only displays a 60 px square.

Active Storage solves this with **variants**: derived versions of the original blob, produced on demand by the image processor and cached on disk. The first request for a given variant generates the resized image; subsequent requests serve the cached file.

Add a small thumbnail (around 60 px square) in the first column of each row of the Pets index, using a variant. The relevant section of the guide is *Transforming Images*: <https://guides.rubyonrails.org/active_storage_overview.html#transforming-images>. The transformation you want is one that resizes and crops the image to fill a fixed square — look for a `resize_to_fill` option.

Do **not** link to the original full-size file from the index, only the resized variant.

### A.8. Update Seeds with Sample Photos

Update `db/seeds.rb` so that on a fresh database (`rails db:drop db:create db:migrate db:seed`):

- Store at least three sample images under `db/seeds/pets/` (commit these files to the repository — pick photos with permissive licenses or take them yourself).
- Attach each of those images to a different pet during seeding. The Active Storage API for attaching a file from disk takes an IO object, a filename, and a content type — read the *Attaching File/IO Objects* section of the guide to find the exact method signature: <https://guides.rubyonrails.org/active_storage_overview.html#attaching-file-io-objects>.

Make sure the seed file is **idempotent enough** that it works on a clean database. You do not need to handle reseeding without dropping.

## Part B — Action Text

Action Text was covered in class, so this part is shorter. The guide is here: <https://guides.rubyonrails.org/action_text_overview.html>.

### B.1. Install

Run the Action Text installer and migrate the database. The installer also adds the necessary JavaScript imports and Trix stylesheet. The relevant section is *Installation*: <https://guides.rubyonrails.org/action_text_overview.html#installation>. Verify in the rendered HTML that the Trix editor styles load.

### B.2. Rich Clinical Notes on Treatment

Replace the plain-text notes on `Treatment` with a rich text attribute called `clinical_notes`. The relevant section of the guide is *Creating Rich Text Content*: <https://guides.rubyonrails.org/action_text_overview.html#creating-rich-text-content>.

- If your `treatments` table has a plain `notes` column from earlier labs, generate a migration to drop it. Action Text data lives in its own polymorphic table, so no column is needed on `treatments` for `clinical_notes`.
- Update the `Treatment` model to declare the rich text attribute.
- Update strong parameters in `TreatmentsController` accordingly.
- Update the Treatment `_form.html.erb` partial to render the rich text editor instead of a plain `text_area`. Wrap it in the standard Bootstrap `mb-3` container with a label.
- On the Appointment **show** page, render each treatment's `clinical_notes`. Action Text returns safe, pre-rendered HTML — you should call the attribute directly, not wrap it in `simple_format` or `sanitize`. See *Rendering Rich Text Content*: <https://guides.rubyonrails.org/action_text_overview.html#rendering-rich-text-content>.

### B.3. Eager-Load to Avoid an N+1

Loading an appointment with several treatments and rendering each treatment's rich content will, by default, issue one extra query per treatment to fetch its rich text body. Action Text generates a `with_rich_text_<attribute>` named scope for exactly this case — read the *Avoiding N+1 Queries* section of the guide: <https://guides.rubyonrails.org/action_text_overview.html#avoiding-n-1-queries>.

Verify in `log/development.log` that the query count is constant regardless of the number of treatments.

### B.4. Sanitization Check

Action Text sanitizes incoming HTML by default — users cannot inject scripts. You do not need any additional sanitization layer.

Verify this once manually: paste `<script>alert(1)</script>` into the Trix editor of a treatment, save, and confirm on the show page that no alert fires and the script tag does not appear in the rendered HTML.

Note your verification in one or two sentences at the bottom of the README of your Lab 7 repo.

## Part C — Enriched Seeds & README

### C.1. Rich-Text Seeds

In addition to the photo attachments from A.8, update `db/seeds.rb` so that at least a handful of treatments have non-empty `clinical_notes` with some basic formatting (a heading, a bullet list, bold text). You can build the rich content as a small HTML string and assign it directly to the rich text attribute — Action Text accepts and stores it.

### C.2. README

Write a short `README.md` at the root of the project that tells the TA:

- How to set up and run the app (`bundle install`, `bin/rails db:setup`, `bin/rails server`).
- That **libvips** is required as a system dependency for image variants, with install instructions for at least one OS.
- The result of your sanitization check from B.4.

## Deliverables

- Active Storage installed and migrated; libvips available locally and documented in the README.
- `Pet` declares an optional single attachment named `photo`, with custom validations on content type (JPEG / PNG / WebP) and size (≤ 5 MB).
- The Pet form uploads a photo, the edit form shows the current one, validation errors render inline, and the form is `multipart/form-data`.
- The Pet show page displays the full photo (or a placeholder); the Pet index displays a 60 px square variant per row.
- Action Text installed and migrated.
- `Treatment` has rich text `clinical_notes`; the form uses the rich text editor; the appointment show page renders the formatted content directly.
- The appointment show page eager-loads `clinical_notes` and avoids an N+1 on rich text bodies.
- Seeds attach photos to several pets and rich-text notes to several treatments, and run cleanly on a fresh database.
- README documents how to run the app, lists libvips as a system dependency, and notes the Trix sanitization check.
