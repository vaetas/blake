# Content

## Page

Page is a single Markdown document with a YAML frontmatter metadata.

```
---
title: Post Title
tags: ['flutter', 'dart']
---

Lorem ipsum dolor sit amet.
```

You can omit YAML fields, but frontmatter delimiter still needs to be used. Below is a minimal example without any YAML metadata.

```
---
---

Lorem ipsum dolor sit amet.
```

Some frontmatter keywords are reserved and you should only use them for defined purposes.

* `title` (String) -- page title.
* `public` (bool) -- when false the page in not build but is still accessible as a data.
* `tags` (List)
* `aliases` (List) -- page that redirect to current page.
* `template` (String) -- select which template to use.
* `date` (String) -- file creation date in ISO format.
* `updated` (String) -- file updated date. By default, when this is not set, git is used to find out last modification date (if possible).

Below is an example frontmatter for Markdown file.

```yaml
title: Post
template: page.html
tags: ['lorem', 'ipsum']
aliases: [
    "/aliased/post/"
]
```