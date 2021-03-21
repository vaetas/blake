---
title: Content
date: 2021-03-21
template: page.html
---

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

### Data pages

Imagine a scenario where you want to have a *Projects* page with 
a list of all your projects. Every project contains name, description, 
and repository.

First option is to create single Markdown file and put each project 
into a shortcode.

Section option is to create a directory called `projects` with `_index.md` 
file. Then, for every project create another Markdown file within 
this directory and declare `public: false` in its frontmatter. 

Now you can create special template for Projects page and access all subpages. 
You can loop through them and display them one by one. These subpages will not 
be rendered as a seperated pages but you can still access them from `_index.md` 
file.

```text
├── content
│  ├── projects
│  │  ├── _index.md
│  │  ├── blake.md
│  │  └── gh_pages.md
```

Your directory will have structure as in the example above. However, your published 
page will only have `/projects/` path rendered. If you try to visit `/projects/blake/` 
you will see a 404 error.