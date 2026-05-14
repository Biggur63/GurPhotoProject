# GurFoto SE

## Static web site for data recovery company

- Hugo static site generator ([link](https://gohugo.io/))
- SCSS
- JavaScript
- A11y
- SEO

Link: [](https://)

## Image sanity check

If Hugo suddenly starts failing on `Resize` or `Fill`, run:

```powershell
python tools\check_image_extensions.py
```

The script only checks whether file extensions match the real raster format and does not modify any files.

## Save and deploy

Use one project command instead of manual git/deploy steps:

```powershell
.\tools\save-project.ps1 -Message "Update project"
```

The script checks that `hugo.toml` does not contain a local Windows `cacheDir`, commits changes, tries the saved SSH GitHub path, and falls back to the GitHub API if GitHub DNS/SSH is unstable.
