[![Pub Version](https://img.shields.io/pub/v/blake)](https://pub.dev/packages/blake)
[![GitHub](https://img.shields.io/github/license/vaetas/blake)](https://github.com/vaetas/blake/blob/main/LICENSE)

# Blake: Static Site Generator

> Did he smile his work to see? \
> Did he who made the Lamb make thee?

[Documentation](https://vaetas.github.io/blake/)

Blake is an opinionated static site generator written in Dart lang. 
It is provided as a single binary and can be used even without Dart installed.

Features as of now:

* Markdown support.
* YAML configuration and front-matter.
* Jinja templates. Also usable in Markdown files.
* Live-reload during development.
* Compiled into single native binary.
* YAML/JSON data content and non-public Data pages.
* Pre-defined content types for quick creation.
* Generated JSON search index.
* `sitemap.xml` generation.
* Inline & body shortcodes.

Remember that this project is WIP. Everything can change at any time.

## Install

You can download compiled binary on [release page](https://github.com/vaetas/blake/releases). Builds are currently done manually and not every platform (i.e. Windows/Mac/Linux) will be available for each release.

Another option is using `pub global activate blake`.

## Usage

Use `blake init` to setup a new project in the current directory. `blake init <name>` will setup the project inside the `<name>` directory.

Use `blake build` to generate the site from your files. By default, generated files will be outputted into the `public` folder.

Use `blake serve` to start a webserver to see your site instantly. The site will be rebuilt every time you change files in your project and the browser tab will be reloaded automatically.

Use `blake new` to create new content based on types defined in `types` folder.

And as usual, `blake` or `blake help` will show usage help.

## Structure

`content` directory contains all Markdown files which will be transformed into HTML files.

`static` directory files will be copied into the `public` folder without change.

`public` contains generated files.

`templates` should contain templates which will be used to process Markdown files inside `content`.

`data` contains YAML/JSON files which you can use inside templates.

`types` is used by the `new` command to quickly create content.

`config.yaml` configures build options for your site.

## Build

You can build Blake into a single native binary. As of now, this binary can only be run on the same platform it was built on. Once compiled, you can run Blake without needing to install Dart SDK.

To compile this project, you need to install [grinder package](https://pub.dev/packages/grinder).

```
pub global activate grinder
```

Then you can run the `grind compile` script to produce a native binary together with an archive. This command will output a binary and an archive into the `build` directory.

```
grind compile
```

You can also run this project without compiling it to the binary.

```
dart bin/blake.dart
```

Or you can activate Blake globally from a local path which is useful during development.

```
pub global activate --source path .
```