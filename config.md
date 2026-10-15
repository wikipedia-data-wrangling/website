+++
author = "wikipedia-data-wrangling"
ignore = ["node_modules/", "README.md", "LICENSE", "Project.toml", "Manifest.toml"]

website_title = "Wikipedia as data"
website_descr = "English Wikipedia's edit history and protection record, loaded into PostgreSQL and audited."
website_url = "https://wikipedia-data-wrangling.github.io/website/"
# Served as a GitHub project page, so every root-relative link gets this prefix
# at build time (optimize(prepath=...) in .github/workflows/deploy.yml).
prepath = "website"

content_tag = ""
generate_rss = false
+++
