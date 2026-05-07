````md
# Lab 7 — VetClinic

## Set
```bash
bundle install
bin/rails db:setup
bin/rails server
````
Then open [http://localhost:3000](http://localhost:3000).

## Dep

you need `libvips` installed.

Ubuntu/Debian:

```bash
sudo apt install libvips
```

Arch:

```bash
sudo pacman -S libvips
```

macOS (Homebrew):

```bash
brew install vips
```

## checks

I add `<script>alert(1)</script>` inside of text treatment.
