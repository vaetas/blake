---
title: Shortcodes
date: 2021-03-21
template: page.html
---

Shortcodes can be used inside your Markdown files. They are replaced template values before parsing Markdown.

## Usage

Put shortcodes inside `templates/shortcodes` directory. The name of the shortcode should contain only lowercase letters, dash, or underscore. The expected file extension for shortcodes is `.html`.

> Example shortcode names: `code.html`, `youtube.html` or `my-shortcode.html`.

Shortcodes folder does not allows subfolders. Only files inside the `template/shortcodes` are used and any subdirectories are omitted.

See an example of a shortcode called `block.html`:

```html
<div class="block">
  <div class="block-title">
    {{ name }}
    {{ surname }}
  </div>

  {{ body }}
</div>
```

You could use this shortcode in your Markdown file with the following syntax:

```markdown
**Hello world**
This is some text.

{{< block name="John" surname="Doe" />}}
```

You can also have body-styled shortcodes. They must use `{{< shortcode >}}` syntax and have a `{{< /shortcode >}}` end tag.

The `body` template variable is by default set to the body of the shortcode. If you also use a custom argument called `body`, your argument will have a precedence.

```markdown
**Hello world**
This is some text.

{{< block name="John" surname="Doe" >}}
This is a body of the shortcode.
{{< /block >}}
```