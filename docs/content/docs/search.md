---
title: Search
date: 2021-03-21
template: page.html
---

Blake allows generating a JSON page index for static site search. 
There is currently no client-side implementation, and you must do it 
yourself.

## Enable

Search index generation is disabled by default. You can enable it inside your `config.yaml` file.

```yaml
build:
  generate_search_index: true
```

## Usage

When you enable index generation, the build command will also create a `search_index.json` file inside the `public` directory.

For example, when you start a local Blake server you can access the index on `http://127.0.0.1:4040/search_index.json`.


## Format

For now, the JSON format is very plain (this will change in the future). You can only access `title` and `url` attributes for a page. Therefore, you can only search through page titles and *not* the content.

```json
[
  {
    "title":"Home",
    "url":"http://127.0.0.1:4040/"
  },
  {
    "title":"Post",
    "url":"http://127.0.0.1:4040/post/"
  },
  {
    "title":"Projects",
    "url":"http://127.0.0.1:4040/projects/"
  },
]
```