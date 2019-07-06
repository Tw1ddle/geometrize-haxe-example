package;

import format.png.Data;
import format.png.Data.Header;
import format.png.Reader;
import format.png.Tools;
import format.png.Writer;
import geometrize.Model.ShapeResult;
import geometrize.Util;
import geometrize.bitmap.Bitmap;
import geometrize.exporter.ShapeJsonExporter;
import geometrize.exporter.SvgExporter;
import geometrize.runner.ImageRunner;
import geometrize.runner.ImageRunnerOptions;
import geometrize.shape.ShapeType;
import haxe.io.Path;
import sys.io.File;
import sys.io.FileInput;
import sys.io.FileOutput;

using StringTools;

/**
   Minimal native (C++ target) demo using Geometrize Haxe to recreate images with geometric primitives
   Pass in command line options to transform an image into shapes, for example:

   ./Main.exe -i monarch_butterfly.png -o monarch_butterfly_out.png -t rotated_rectangle -s 500

   @author Sam Twidale (https://www.geometrize.co.uk/)
 */
class Main extends mcli.CommandLine
{
	/**
	   The filepath to load the input image from
	**/
	public var i:String = null;
	/**
	   The filepath to save the output image, JSON data or SVG
	**/
	public var o:String = null;
	/**
	   The type of shape to use. One of: rectangle, rotated_rectangle, triangle, ellipse, rotated_ellipse, circle, line, quadratic_bezier, polyline
	**/
	public var t:String = "rotated_rectangle";
	/**
	   Number of shapes to use in the output image
	**/
	public var s:Int = 250;
	/**
	   The number of candidate shapes per shape added to the output image
	**/
	public var c:Int = 500;
	/**
	   The maximum number of times to mutate each candidate shape
	**/
	public var m:Int = 100;
	/**
	   The opacity (0-255) of each shape added to the output image
	**/
	public var a:Int = 128;
	
	public function runDefault() {
		Sys.println("Running Geometrize Haxe...");
		
		// Read the input image
		var sourceBitmap:Bitmap = readPNGImage(new Path(i));
		if (sourceBitmap == null) {
			Sys.println("Failed to read PNG image at: " + i);
			return;
		}
		
		// Populate the image runner options
		var imageRunnerOptions:ImageRunnerOptions = {
			shapeTypes: [ stringToShapeType(t) ],
			alpha: a,
			candidateShapesPerStep: c,
			shapeMutationsPerStep: m
		};
		
		// Create image runner and add shapes one by one
		var runner:ImageRunner = new ImageRunner(sourceBitmap, Util.getAverageImageColor(sourceBitmap));
		var shapeData:Array<ShapeResult> = [];
		for (count in 0...s) {
			var results = runner.step(imageRunnerOptions);
			for (result in results) {
				shapeData.push(result);
				Sys.println(Std.string(count) + ": Adding shape of type " + Std.string(result.shape.getType()));
			}
		}
		
		// Save the output image/data
		if (o.endsWith(".png")) {
			try {
				writePNGImage(new Path(o), runner.getImageData());
			} catch (e:Dynamic) {
				Sys.println("Failed to save PNG image to disk with exception: " + Std.string(e));
			}
		} else if (o.endsWith(".svg")) {
			try {
				writeSVGImage(new Path(o), SvgExporter.export(shapeData, sourceBitmap.width, sourceBitmap.height));
			} catch(e:Dynamic) {
				Sys.println("Failed to save SVG data to disk with exception: " + Std.string(e));
			}
		} else if (o.endsWith(".json")) {
			try {
				writeJSONData(new Path(o), ShapeJsonExporter.export(shapeData));
			} catch (e:Dynamic) {
				Sys.println("Failed to save JSON data to disk with exception: " + Std.string(e));
			}
		} else {
			Sys.println("Failed to identify output path file extension, it should be .png, .svg or .json");
		}
	}
	
	private function new() {
		super();
	}
	
	// Prints command-line help string
	public function help() {
		Sys.println(this.toString());
	}
	
	// Reads a PNG image from disk and returns an RGBA8888 bitmap
	private static function readPNGImage(filePath:Path):Bitmap {
		try {
			var handle:FileInput = sys.io.File.read(filePath.toString(), true);
			var d:Data = new format.png.Reader(handle).read();
			var hdr:Header = format.png.Tools.getHeader(d);
			handle.close();
			
			// Convert data to RGBA format
			var bytes = Tools.extract32(d);
			Tools.reverseBytes(bytes);
			var rgba = PixelFormatHelpers.argbToRgba(bytes);
			
			return Bitmap.createFromBytes(hdr.width, hdr.height, rgba);
		} catch (e:Dynamic) {
			return null;
		}
	}
	
	// Writes an RGBA8888 Bitmap to disk as a PNG image
	private static function writePNGImage(filePath:Path, bitmap:Bitmap):Void {
		var output:FileOutput = sys.io.File.write(filePath.toString(), true);
		new format.png.Writer(output).write(format.png.Tools.build32BGRA(bitmap.width, bitmap.height, PixelFormatHelpers.rgbaToBgra(bitmap.getBytes())));
	}
	
	// Writes an SVG image to disk
	private static function writeSVGImage(filePath:Path, svgData:String):Void {
		sys.io.File.saveContent(filePath.toString(), svgData);
	}
	
	// Writes shape JSON data to disk
	private static function writeJSONData(filePath:Path, jsonData:String):Void {
		sys.io.File.saveContent(filePath.toString(), jsonData);
	}
	
	// Try to convert a string to a shape type
	private static function stringToShapeType(type:String):ShapeType {
		return switch(type) {
			case "rectangle":
				ShapeType.RECTANGLE;
			case "rotated_rectangle":
				ShapeType.ROTATED_RECTANGLE;
			case "triangle":
				ShapeType.TRIANGLE;
			case "ellipse":
				ShapeType.ELLIPSE;
			case "rotated_ellipse":
				ShapeType.ROTATED_ELLIPSE;
			case "circle":
				ShapeType.CIRCLE;
			case "line":
				ShapeType.LINE;
			case "quadratic_bezier":
				ShapeType.QUADRATIC_BEZIER;
			default:
				Sys.println("Did not recognize provided shape type string, defaulting to circles");
				ShapeType.CIRCLE;
		}
	}
	
	// Entry point
	private static function main() {
		new mcli.Dispatch(Sys.args()).dispatch(new Main());
	}
}