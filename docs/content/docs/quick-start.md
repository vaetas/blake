---
title: Quick start guide
template: page.html
date: 2021-03-22
---

Install Blake using `pub`.

```text
pub global activate blake
```

Initialize new project. This generates `config.yaml` file and 
used directories for content and templates.

```text
# Create new project in current directory
blake init

# Create new project in `website` directory
blake init website
```

Start local development server with auto-reload.

```text
blake serve
```

You should see a URL address in your terminal if the server started 
successfully. Open it in your browser. By default, this address is [http://127.0.0.1:4040/](http://127.0.0.1:4040/).

Because the initialized project does not have content or templates, 
you must create them first.

Inside `templates` directory create `page.html` template. Use [templates docs](https://vaetas.github.io/blake/docs/templates/) 
as a reference.

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

Now inside `content` create `_index.md` page.

```markdown
---
title: Homepage
template: page.html
---

Hello world.
```

The YAML config inside `---` is called the frontmatter. You can access these values inside 
your templates by its keys. The Markdown body (*Hello world.*) can be accessed using `content` key 
in the templates.

Now you need to reload your browser tab to properly initialize live-reload script. This 
script is only injected into generated HTML pages and because we have only created the first 
page now, live-reload will not work without manual reload. Subsequent edits will trigger 
reloads correctly in your browser.