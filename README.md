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

 * Compute PSNR from frame 1001 to 1500

    ./qpsnr -s 1000 -m 500 -r reference_video.avi video1.avi video2.avi video3.avi

 * Compute average PSNR in HSI colorspace for the first 500 frames

    ./qpsnr -m 500 -a avg_psnr --aopts fpa=25:colorspace=hsi -r reference_video.avi video1.avi video2.avi video3.avi

 * Compute PSNR in YCbCr colorspace skipping the first 2000 frames and storing each frame in ppm format.

    ./qpsnr -I -s 2000 --aopts colorspace=ycbcr -r reference_video.avi video1.avi video2.avi video3.avi

 * Same as above but save in jpeg format instead of ppm

    ./qpsnr -J -s 2000 --aopts colorspace=ycbcr -r reference_video.avi video1.avi video2.avi video3.avi
