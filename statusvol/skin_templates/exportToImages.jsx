/**
* Remixer: @herkulano (http://www.herkulano.com)
* Thanks to: Niels Bosma (niels.bosma@motorola.com)
* 
* Modified for StatusVol .ai -> @1x, @2x, @3x
* 
* Copyright (c) 2011 http://www.herkulano.com
* 
* Permission is hereby granted, free of charge, to any person obtaining
* a copy of this software and associated documentation files (the
* "Software"), to deal in the Software without restriction, including
* without limitation the rights to use, copy, modify, merge, publish,
* distribute, sublicense, and/or sell copies of the Software, and to
* permit persons to whom the Software is furnished to do so, subject to
* the following conditions:
* 
* The above copyright notice and this permission notice shall be
* included in all copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
* NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
* LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
* OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
* WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

var folder = Folder.selectDialog();
var document = app.activeDocument;
var xyScale,
	oldHeight, newHeight;

if (document && folder) {
	oldHeight = 12;
	newHeight = 10;
	
	xyScale = parseInt(newHeight)/oldHeight || 1;

	saveToRes(100, "", xyScale);
	saveToRes(200, "@2x", xyScale);
	saveToRes(300, "@3x", xyScale);
}

function saveToRes(scaleTo, densitySuffix, xyScale) {
	var i, layer,
		file, options;

	for (i = document.layers.length - 1; i >= 0; i--) {
		layer = document.layers[i];
		if (!layer.locked) {
			hideAllLayers();
			layer.visible = true;

			file = new File(folder.fsName + "/" + layer.name + densitySuffix + ".png");

			options = new ExportOptionsPNG24();
			options.antiAliasing = true;
			options.transparency = true;
			options.horizontalScale = scaleTo * xyScale;
			options.verticalScale = scaleTo * xyScale;

			document.exportFile(file, ExportType.PNG24, options);
		}
	}
}

function hideAllLayers() {
	var i, layer;

	for (i = document.layers.length - 1; i >= 0; i--) {
		layer = document.layers[i];
		if (!layer.locked) {
			layer.visible = false;
		}
	}
}