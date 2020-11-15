# Blake: Static Site Generator

> Did he smile his work to see? \
> Did he who made the Lamb make thee?

Blake is an experimental static site generator in Dart language.

Features as of now:

* Markdown support.
* YAML configuration and front-matter.
* Mustache templates.
* Live-reload.
* Single native binary.

Remember that this project is WIP. Everything can change at any time.

## Usage

Use `blake init` to setup a new project in the current directory. `blake init <name>` will setup the project inside the `<name>` directory.

Use `blake build` to generate the site from your files. By default, generated files will be outputted into the `public` folder.

Use `blake serve` to start a webserver to see your site instantly. The site will be rebuilt every time you change files in your project and the browser tab will be reloaded automatically.

And as usual, `blake` or `blake help` will show usage help.

## Structure

`content` directory contains all Markdown files which will be transformed into HTML files.

`static` directory files will be copied into `public` folder without change.

`public` contains generated files.

`templates` should contain templates which will be used to process Markdown files inside `content`.

`config.yaml` configures build options for your site.

## Build

To create native binary use the following command. You need to have installed full Dart SDK at your computer (Dart packaged with Flutter is not enough).

```
# Windows
dart2native bin/blake.dart -o bin/blake.exe

# Linux or macOS
dart2native bin/blake.dart -o bin/blake
```

You can also run this project without compiling native binary.

```
dart bin/blake.dart
```

## Activate `blake` globally

Use `blake` everywhere by using `pub global activate --source path .` inside this project's root.