---
title: Templates
date: 2021-03-21
template: page.html
jinja: true
---

Blake uses [jinja templates](https://jinja.palletsprojects.com/en/2.11.x/) 
for HTML generation. There is currently only [single](https://pub.dev/packages/jinja) 
jinja package for Dart and it does not support every functionality. However,
variables, expressions, control structures, and template inheritance works.

Template must have a `.html` extension. All templates must be within `templates` 
directory (you can customize this location in `config.yaml`).

```text
├── templates
│  ├── shortcodes
│  └── page.html
```

Templates directory contains `shortcodes` subdirectory. This directory 
must be used to place your [shortcodes]({{ site.baseUrl }}docs/shortcodes/). Therefore, by default all shortcodes
should be located in `templates/shortcodes/` directory.

Below is an example of a simple template for pages.

{% raw %}
```html
<!doctype html>
<html lang="en">
<head>
    <title>{{ title }}</title>
</head>
<body>
    {{ content }}
</body>
</html>
```
{% endraw %}