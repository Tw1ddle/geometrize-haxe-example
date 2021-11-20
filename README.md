[![Project logo](https://github.com/Tw1ddle/geometrize-haxe-example/blob/master/screenshots/geometrize_haxe_example_logo.png?raw=true "Geometrize Haxe recreating images as geometric primitives logo")](https://www.geometrize.co.uk/)

[![License](https://img.shields.io/:license-mit-blue.svg?style=flat-square)](https://github.com/Tw1ddle/geometrize-haxe-example/blob/master/LICENSE)
[![Geometrize Build Status](https://ci.appveyor.com/api/projects/status/github/Tw1ddle/geometrize-haxe-example)](https://ci.appveyor.com/project/Tw1ddle/geometrize-haxe-example)

Minimal example of the [Geometrize Haxe library](https://github.com/Tw1ddle/geometrize-haxe/), a Haxe library for converting images into shapes.

## Building

Install the dependencies:

```
haxelib install hxcpp
haxelib install format
haxelib install mcli
haxelib install Sure
```

Either open the project folder in VSCode, or run Haxe from the command line:

```
haxe GeometrizeHaxeExample.hxml
```

## Usage

This demo works on the C++ target. Move the built binary to the [sample images](https://github.com/Tw1ddle/geometrize-haxe-example/tree/master/sample_images) folder and start geometrizing some images. Pass command line options to specify the options the program should use for converting images into shapes.

```
# Create an image made of 400 circles
./Main.exe -i sliced_fruit.png -o sliced_fruit_out.png -t circle -s 400
```

[![Geometrize Fruit Example](https://github.com/Tw1ddle/geometrize-haxe-example/blob/master/screenshots/sliced_fruit.png?raw=true "Geometrize Fruit Example")](https://www.geometrize.co.uk)

## Options

Flag            | Description    | Default    |
--------------- | ---------------| ---------|
i               | The filepath to load the input image from | n/a
o               | The filepath to save the output image, JSON data or SVG | n/a
t               | The type of shape to use | One of: rectangle, rotated_rectangle, triangle, ellipse, rotated_ellipse, circle, line, quadratic_bezier, polyline
s               | Number of shapes to use in the output image | 250
c               | The number of candidate shapes per shape added to the output image | 500
m               | The maximum number of times to mutate each candidate shape | 100
a               | The opacity (0-255) of each shape added to the output image | 128

## Notes
 * Got an idea or suggestion? Open an issue or send Sam a message on [Twitter](https://twitter.com/Sam_Twidale).