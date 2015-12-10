# Footage-Manipulation
## Introduction
This project provides tools to help with the manipulation of the footage. The currently available tools are 

* the **calibration** of the camera using a checkerboard _(tools/calibrate.cpp)_, 
* the **undistortion** of the footage _(tools/undistort.cpp)_,
* the **stabilization** of the footage _(tools/undistort.cpp)_ and
* the **splitting** of the footage into sub rectangles. _(tools/split_vid)_

## How to Build and Run

### Dependencies
1. C++11 compiler
2. OpenCV2
3. BOOST libraries
4. CMake

### Steps
1. Install dependencies if not already done.
2. Make a new directory to compile the code into 
```
$> mkdir manip_bin
```
3. Change into that directory
```
$> cd manip_bin
```
4. CMake the project
```
$> cmake ..
```
5. Make the project 
```
$> make
```
6. Run the tool you want to use
```
$> tools/[Your tool of choice]
```

## What each tool does
### Calibrate
This is the calibration software for the camera.

#### How do you use it?
```
Usage: tools/calibrate [options] <horiz> <vert> <input>

Options:
  -h [ --help ]	Print help messages
  --horiz arg                       Number of horizontal corners
  --vert arg                        Number of vertical corners
  -i [ --input ] arg                Input directory
  -c [ --calibfn ] arg (=calib.yml) calibration filename
```
#### What does it do?
Takes in a directory that contains all the calibration images that you have with the checkerboard and writes the corresponding calibration output file.

### Undistort
This is the undistortion software for the camera.

#### How do you use it?
```
Usage: tools/undistort [options] <calibfn> <footage>

Options:
  -h [ --help ]         Print help messages
  -c [ --calibfn ] arg  calibration filename
  -f [ --footage ] arg  footage file
```
#### What does it do?
Takes in the footage that you have recorded as well as the calibration file that was created from the **calibration** tool and undistorts the footage.

N.B. For now we do not save the video.

### Stabilize
This is the stabilization software for the camera.

#### How do you use it?
```
Usage: tools/stabilize [options] <footage>

Options:
  -h [ --help ]                     Print help messages
  -b [ --boxsize ] arg (=20)        The size of the box that you search for the
                                    best point to track in
  -c [ --hcrop ] arg (=30)          Horizontal Border Crop, crops the border to
                                    reduce the black borders from stabilization
                                    being too noticeable.
  -m [ --manualframe ] arg (=0)     Frame to do manual capturing on.
  -e [ --endframe ] arg(= end of video ) Frame to stop stabilization at.
  -s [ --scalefactor ] arg (=0.25)  Scaling Factor for manual marking.
  -i [--ransac_max_iters ] arg(=500) Maximum number of iterations for RANSAC.
  -g [--ransac_good_ratio] arg(=0.9) Inlier Ratio used for RANSAC.
  -f [ --footage ] arg              footage file
  -o [ --output ] arg (=output.avi) output file

```

When run, manually select the points that you want to track.
#### What does it do?
Takes in the footage that you have recorded and creates the corresponding stabilized footage. 

### Alternative Stabilize
Video stablization that smooths the global trajectory using a sliding average window
```
Usage: Modify and run the ruby script cv3stab.rb
```


### Splitting
This is the splitting software for the footage.

#### How do you use it?
```
Usage: tools/split_vid [options] <footage> <numx> <numy>

Options:
  -h [ --help ]               Print help messages
  -f [ --footage ] arg        footage file
  -x [ --numx ] arg           number of x splits
  -y [ --numy ] arg           number of y splits
  -t [ --timesplit ] arg (=1) number of time splits
  -s [ --threads ] arg (=4)   number of threads
  -o [ --output ] arg (=.)    output directory
  -l [ --overlap ] arg (0)    number of pixels to overlap spatially between splits.
```
#### What does it do?
Takes in the stabilized footage and splits it into the number of rectangles and time zones that you would like.


### Preprocess subfolder
This folder contains a number of scripts to apply to the stabilized videos as a recent alternative to using the above splitting code.

#### get_box.py
requires extract_valid_track.py
Provided a stabilized video, crop a bounding box from the interior such that there isn't much black at the edges. 
```
Usage: python get_box.py input_frames output_frames
Must modify the input frames and output frames base directory in the get_box.py file.
```
#### split_frames.py
 Splits a video spatially. 
 ```
Input: directory of frames, Output: some number of directories where each directory stores a spatial split. Also, contains a method to resize frames, without splitting.
Must modify the input frames and output frames base directory in the split_frames.py file.
```
#### split_frames_wrapper.py
A wrapper script that calls split_frames.py to split & rescale many videos using a ThreadPool.
Requires author to generate a split_frames_todo.txt file of the following format:
frames_directory (x,y) overlap
e.g:
bookstore4k-09-29-5pu (2,3) 100 
bookstore4k-09-29-11a40u (2,3) 100
bookstore4k-10-5-11a40u (2,2) 200
bookstore4k-10-06-4p50u (2,2) 200
bytes4k-09-25-12pu (2,3) 200
```
Must modify the paths in this script before usage.
```

#### rescale_frames_wrapper.py
 A wrapper script that calls split_frames.py to rescale many videos using a ThreadPool.
```
Must modify the paths in this script before usage.
```

### Postprocess subfolder

#### scratch_reformat.m
Reformats the annotation.mat files (output by vatic) into a format required by Alex R. This file is saved into obsmat.mat

#### relabelGUI.m/fig
GUI interface built to facilitate relabeling the objects in the annotations.mat files.

#### alexGUI.m
A last-minute GUI built to display the trajectories (provided by Alex. R) to generate figures. (not completed)








