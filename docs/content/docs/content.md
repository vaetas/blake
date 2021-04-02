---
title: Content
date: 2021-03-21
template: page.html
jinja: true
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

You can omit YAML fields, but frontmatter delimiter is still required. Below is a minimal example without any YAML metadata.

```
---
---

Lorem ipsum dolor sit amet.
```

Some frontmatter keywords are reserved, and you should only use them for defined purposes.

| Key      | Type           | Default | Description                             |
|----------|----------------|---------|-----------------------------------------|
| title    | String         |         | Title of the page                       |
| template | String         |         | Name of the template (e.g. `page.html`) |
| public   | bool           | true    | Generate HTML from this page            |
| tags     | List\<String\> |         | Page tags                               |
| aliases  | List\<String\> |         | Redirects to this page                  |
| date     | String         |         | Create date                             |
| updated  | String         |         | Update date                             |
| jinja    | bool           | false   | Allow jinja templates in Markdown       |

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

## Markdown

Blake uses [markdown](https://pub.dev/packages/markdown) package for rendering.

## Jinja in Markdown

Pages can optionally use Jinja templating. This behavior is disabled by default. You can enable it
by settings `jinja` frontmatter param to `true`. If you don't need to access Jinja variables inside the
file leave this turned off for better performance.

For example, you can use this to access site properties, like base URL, inside your content.

{% raw %}
```markdown
## Header
Click [on this link]({{ site.baseUrl }}) to go home.
```
{% endraw %}

Jinja templates are rendered first, then the shortcodes, and Markdown is rendered last. You can
therefore use Jinja inside your shortcodes easily.