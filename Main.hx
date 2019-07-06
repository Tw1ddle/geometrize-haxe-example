package;

import format.png.Data;
import format.png.Data.Header;
import format.png.Reader;
import format.png.Tools;
import format.png.Writer;
import geometrize.Model.ShapeResult;
import geometrize.Util;
import geometrize.bitmap.Bitmap;
import geometrize.bitmap.Rgba;
import geometrize.exporter.SvgExporter;
import geometrize.runner.ImageRunner;
import geometrize.runner.ImageRunnerOptions;
import geometrize.shape.ShapeType;
import haxe.io.Path;
import sys.io.File;
import sys.io.FileInput;
import sys.io.FileOutput;

/**
 * Minimal native (C++ target) demo using Geometrize Haxe to recreate images with geometric primitives.
 * @author Sam Twidale (https://www.geometrize.co.uk/)
 */
class Main
{
	// Reads a PNG image from disk and returns an RGBA8888 bitmap
	private static function readPNGImage(filePath:Path):Bitmap {
		var handle:FileInput = sys.io.File.read(filePath.toString(), true);
		var d:Data = new format.png.Reader(handle).read();
		var hdr:Header = format.png.Tools.getHeader(d);
		handle.close();
		
		// Convert data to RGBA format
		var bytes = Tools.extract32(d);
		Tools.reverseBytes(bytes);
		var rgba = PixelFormatHelpers.argbToRgba(bytes);
		
		return Bitmap.createFromBytes(hdr.width, hdr.height, rgba);
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
	
	// TODO options from ini file or command line?
	private static function main() {
		var imageRunnerOptions:ImageRunnerOptions = {
			shapeTypes: [ ShapeType.CIRCLE, ShapeType.ELLIPSE, ShapeType.ROTATED_ELLIPSE ],
			alpha: 128,
			candidateShapesPerStep: 250,
			shapeMutationsPerStep: 50
		};
		var sourceImagePath:Path = new Path("../sample_images/grapefruit.png");
		var sourceBitmap:Bitmap = readPNGImage(sourceImagePath);
		var backgroundColor:Rgba = Util.getAverageImageColor(sourceBitmap);
		var runner:ImageRunner = new ImageRunner(sourceBitmap, backgroundColor);
		
		// TODO
		var shapeData:Array<ShapeResult> = [];
		for (i in 0...500) {
			var results = runner.step(imageRunnerOptions);
			for (result in results) {
				shapeData.push(result);
			}
		}
		
		try {
			writeSVGImage(new Path("output.svg"), SvgExporter.export(shapeData, sourceBitmap.width, sourceBitmap.height));
		} catch(e:Dynamic) {
			// TODO
		}
		
		try {
			writePNGImage(new Path("output.png"), runner.getImageData());
		} catch (e:Dynamic) {
			// TODO
		}
	}
}