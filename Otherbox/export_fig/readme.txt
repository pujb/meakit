http://www.mathworks.com/matlabcentral/fileexchange/23629-exportfig

Description 	

This function saves a figure or single axes to one or more vector and/or bitmap file formats, and/or outputs a rasterized version to the workspace, with the following properties:
   - Figure/axes reproduced as it appears on screen
   - Cropped borders (optional)
   - Embedded fonts (vector formats)
   - Improved line and grid line styles
   - Anti-aliased graphics (bitmap formats)
   - Render images at native resolution (optional for bitmap formats)
   - Transparent background supported (pdf, eps, png)
   - Semi-transparent patch objects supported (png only)
   - RGB, CMYK or grayscale output (CMYK only with pdf, eps, tiff)
   - Variable image compression, including lossless (pdf, eps, jpg)
   - Optionally append to file (pdf, tiff)
   - Vector formats: pdf, eps
   - Bitmap formats: png, tiff, jpg, bmp, export to workspace

This function is especially suited to exporting figures for use in publications and presentations, because of the high quality and portability of media produced.

Note that the background color and figure dimensions are reproduced (the latter approximately, and ignoring cropping & magnification) in the output file. For transparent background (and semi-transparent patch objects), set the figure (and axes) 'Color' property to 'none'; pdf, eps and png are the only file formats to support a transparent background, whilst the png format alone supports transparency of patch objects.

When exporting to vector format (pdf & eps), and to bitmap using the painters renderer, this function requires that ghostscript is installed on your system. You can download this from:
   http://www.ghostscript.com
When exporting to eps it additionally requires pdftops, from the Xpdf suite of functions. You can download this from:
   http://www.foolabs.com/xpdf

Usage examples can be found at:
http://sites.google.com/site/oliverwoodford/software/export_fig

When reporting bugs, please use the 'Contact Author' link on my Author page, rather than pasting the error into the comments - I will respond more quickly, especially if I can email you back.