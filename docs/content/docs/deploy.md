---
title: Deploy
date: 2021-03-21
template: page.html
---

When you run `blake build` the content is generated into `public` 
directory. Markdown files are rendered into HTML using templates and 
files from `static` directory are copied into `public` without any change.

You can deploy the content of `public` directory to your website.

## Github Pages

Install [gh_pages](https://pub.dev/packages/gh_pages) package and run following 
command.

```text
gh_pages public
```

This creates branch `gh-pages` if it does not exist and copies files from `public` 
dir into this branch. Finally, it pushes the changes to your remote repository. 

You will also need to [configure Github Pages](https://docs.github.com/en/github/working-with-github-pages/creating-a-github-pages-site) 
in your repository for this to work.

## Netlify

Netlify will require custom build script that is not yet implemented. It is planned, 
although it is not a priority.