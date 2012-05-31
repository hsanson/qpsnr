QPSNR
=====

This is a fork of the qpsnr tool [qpsnr] (http://qpsnr.youlink.org/).

# What's New

 * Fixed compilation to work with the avcodec and avformat libraries that come with Ubuntu 12.04.
 * Removed the -g flag from the make file (faster processing).
 * Added a new -J flag that saves frames in JPEG format (requires libjpeg62-dev).

# Compilation

Install the required packages:

	sudo apt-get install g++ libavcodec-dev libavformat-dev libswscale-dev libjpeg62-dev

then compile the source:

	make

# Usage

After compilation a `qpsnr` binary should appear in the current directory. You
can copy it to your bin folder or add the binary path to your PATH environment.

Compute PSNR from frame 1001 to 1500

    ./qpsnr -s 1000 -m 500 -r reference_video.avi video1.avi video2.avi video3.avi

Compute average PSNR in HSI colorspace for the first 500 frames

    ./qpsnr -m 500 -a avg_psnr --aopts fpa=25:colorspace=hsi -r reference_video.avi video1.avi video2.avi video3.avi

Compute PSNR in YCbCr colorspace skipping the first 2000 frames and storing each frame in ppm format.

    ./qpsnr -I -s 2000 --aopts colorspace=ycbcr -r reference_video.avi video1.avi video2.avi video3.avi

Same as above but save in jpeg format instead of ppm

    ./qpsnr -J -s 2000 --aopts colorspace=ycbcr -r reference_video.avi video1.avi video2.avi video3.avi

QPSNR.rb
========

This is a helper ruby script that works like qpsnr but it generates a nice html
page with a nice SSIM or PSNR graph were each point has a link to the
corresponding original and encoded frames.

# Requirements

You must have ruby 1.9.2 installed in your system. In Ubuntu the following
command should suffice:

    sudo apt-get install ruby1.9.1

For this script to work you must have the qpsnr binary and the scripts directory
that comes with the source in the same folder. This ruby script depends on these
files to generate the html output.

# Usage

Similar to qpsnr with some small differences:

 * The -J flag is set on by default.
 * The --aopts flag is replaced by two new flags (-colorspace, -bs).
 * You cannot use average analyzers (avg_ssim or avg_psnr).

    /path/to/qpsnr.rb -m 400 -r ref.avi out1.mp4 out2.mp4 ... outN.mp4

# HTML Interaction

The resulting html page has the same name of the reference clip with the
extension changed to html. If you open this html file in a browser you should
see:

  * The first frame of the original clip.
  * The first frame of the first input (encoded) clip.
  * A flot graph of the SSIM or PSNR depending on what you used.

You can click any item in the graph and the corresponding encoded frame will be
replaced. Also you may use the left and right arrows on the keyboard to navigate
the points in the graph. The up and down arrow allows to select different input
(encoded) clips in case you had more than one.

# Warnings

Depending on the size of the media files you are comparing this tool may take a
long time and huge amounts of hard disk. This tool will output a JPEG image for
each frame of each input and reference clip on disk so do not run this on large
files on your ultrabook 160GB SSD harddisk.

Please note that the displayed frames are JPEG encoded and scaled so they are
not exactly the same frames used for calculating the SSIM or PSNR values. I did
not made this viewer to check encoding quality visually, instead I did this to
check that the frames being compared are actually the same frame.
