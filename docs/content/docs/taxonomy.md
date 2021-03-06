---
title: Taxonomy
date: 2021-03-21
template: page.html
jinja: true
---

## Tags

Page tags can be specified using `tags` inside your frontmatter. They are optional, and you can leave them entirely.

```
---
title: Example post
tags: ['lorem', 'ipsum']
---

Lorem ipsum dolor sit amet.
```

So far, no taxonomy pages are generated by default. However, all info about your tags can be accessed from `data` object inside the templates.

`data.tags` is a list of tags and their respective pages. The individual tag has following schema.

```json
{
  'name': 'Your tag name',
  'pages: [
    // Pages with all their data you can access.
  ]
}
```

{% raw %}
```
<!DOCTYPE html>
<html>
<head>
    <title>{{ title }}</title>
</head>
<body>
{{ data.tags }}
</body>
</html>
```
{% endraw %}
