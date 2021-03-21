---
title: Install
date: 2021-03-21
template: page.html
---

## Pub

Easiest way to install Blake is using `pub`. Following 
command installs Blake into your command. However, this 
requires Dart SDk installed.

```text
pub global activate blake
```

## Pre-compiled binary

Compiled binary provides the best possible performance and removes dependency 
on Dart SDK. You can therefore download and run this binary on devices 
without Dart installed.

You can download binaries from our 
[release page](https://github.com/vaetas/blake/releases/latest). 
Builds are currently done manually and we cannot guarantee them 
for every build. If you don't find a binary for your platform you 
will need to compile it yourself.

## Build from source

To build Blake from source clone the [repository](https://github.com/vaetas/blake). 
Compile script uses [grinder](https://pub.dev/packages/grinder) package that you 
need to install into your path by following command.

```text
pub global activate grinder
```

Now go into Blake directory and run following command. This command runs tests 
and if they succeed it starts compilation. The result is two files: a native binary 
(named `blake` or `blake.exe` depending on your platform) and `blake-<platform>.zip` 
archive.

```text
grind compile
```

On macOS, the result would be following.

```text
build
├── blake
└── blake-mac.zip
```

The archive contains only the `blake` binary file and is created out of 
convenience. You don't have to use it.