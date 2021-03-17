# Content

## Page

Page is a single Markdown document with a YAML frontmatter metadata.

Some frontmatter keywords are reserved and you should only use them for defined purposes.

* `title` (String) -- page title.
* `public` (bool) -- when false the page in not build but is still accessible as a data.
* `tags` (List<String>)
* `aliases` (List<String>) -- page that redirect to current page.