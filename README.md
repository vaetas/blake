# Blake: Static Site Generator

> Did he smile his work to see? \
> Did he who made the Lamb make thee?

Blake is an experimental static site generator in Dart language.

## Usage

Use `blake init` to setup a new project in current directory. `blake init name` will setup the project
inside `name` directory.

Use `blake build` to generate the site from your files.

Use `blake serve` to start a webserver to see your site instantly. Site will be rebuilt every time
you change files in your project and the browser tab will be reloaded automatically.

## Structure

`content` directory contains all Markdown files which will be transformed into HTML files.
`static` directory files will be copied into generated site without change.
`public` contains generated files.
`templates` should contain templates which will be used to process Markdown files inside `content`.
`config.yaml` configures build options for your site.

## Build

To create native binary use following command. You need to have installed full Dart SDK at your computer
(Dart packaged with Flutter is not enough).

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