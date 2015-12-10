#!/usr/bin/env python2

import sys
import os
import numpy as np
import subprocess, argparse
import pdb
from PIL import Image


def exec_shell(cmd_line, raise_on_err=False):
  """ Execute a shell statement in a subprocess
    Parameters
    ----------
    cmd_line: string,
              the command line to execute (verbatim)
    raise_on_err: boolean, optional, default: False,
                  whether to raise ValueError if something was dumped to stderr
    Returns
    -------
    stdout, stderr: strings containing the resulting output of the command
    """
  out, err = subprocess.Popen(
    cmd_line,
    shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE
  ).communicate()
  if raise_on_err and err != "":
    raise ValueError("Error: cmd={}, stderr={}".format(cmd_line, err))
  return out.strip(), err.strip()


def split_img(image_dir, output_dir, images, x, y, height, width, overlap, numx, numy, doresize=False, rescale_width=720, rescale_height=480):
  """
  Crops the specified region of the 
  """
  width_ = int(width/numx)
  height_ = int(height/numy)
  this_x = x*width_
  this_y = y*height_
  this_width = width_
  this_height = height_

  if (x > 0):
    this_x -= overlap
    this_width += overlap
  if (y > 0):
    this_y -= overlap
    this_height += overlap
  if (x != numx-1):
    this_width += overlap
  if (y != numy-1):
    this_height += overlap

  cmd = "convert {in_img} -crop {w}x{h}+{ux}+{uy}"
  if doresize:
    cmd += " -resize {width}x{height}!".format(width=rescale_width, height=rescale_height)
  cmd += " {out_img}"

  toreturn = "({x},{y}) -> ({w},{h})".format(x=x,y=y,w=this_width,h=this_height)
  print toreturn
  for image in images:
    in_ = os.path.join(image_dir,image)
    out_ = os.path.join(output_dir,image)
    exec_shell(cmd.format(in_img=in_, w=this_width, h=this_height, ux=this_x, uy=this_y, out_img=out_))
  return toreturn



def run(img_dir,numx,numy,overlap, output_dir_base='/cvgl/group/UAV_data/5-splits-b-noresize/', doresize=False):
  
  img_dir_base = '/cvgl/group/UAV_data/5-crop-b/'
  output_dir = os.path.join(output_dir_base,img_dir)
  img_dir = os.path.join(img_dir_base,img_dir)



  print('splitting {0} into shape ({1},{2})'.format(img_dir,numy, numx))
  toreturn = [img_dir]

  try:
    os.makedirs(output_dir)
  except:
    pass

  images = os.listdir(img_dir)
  input_images = [os.path.join(img_dir,x) for x in images]
  #pdb.set_trace()
  width, height = Image.open(input_images[0]).size

  #height1, width1, _ = cv2.imread(input_images[0]).shape

  for x in range(numx):
    for y in range(numy):
      #print('splitting ({0},{1})'.format(x, y))
      output_dir_xy = os.path.join(output_dir,"{0}-{1}".format(y,x))
      try:
        os.makedirs(output_dir_xy)
      except:
        pass
      #  assert( len(os.listdir(output_dir_xy)) == 0)
      if len(os.listdir(output_dir_xy)) < 100:
        toreturn.append(split_img(img_dir,output_dir_xy,images,x,y,height,width,overlap,numx, numy, doresize=doresize))
  return toreturn


def rescale(img_dir,output_dir,images,rescale_width=720, rescale_height=480):
  """
  Rescales the image to the determind size specified ratio.
  images is a list of images in the img_dir that need to be rescaled.
  """


  try:
    os.makedirs(output_dir)
  except:
    if os.path.exists(output_dir):
      pass
    else:
      print "{0} exists error".format(output_dir)
      raise 

  #images = os.listdir(img_dir)
  #input_images = [os.path.join(img_dir,x) for x in images]
  #pdb.set_trace()
  #height, width, _ = cv2.imread(input_images[0]).shape

  cmd = "convert {in_img} -resize {width}x{height}! {out_img}"
  #toreturn = "{img}: {width}x{height} -> {rescale_width}x{rescale_height}".format(img=os.path.basename(img_dir.strip("/")), width=width,height=height,rescale_width=rescale_width,rescale_height=rescale_height)
  for image in images:
    in_ = os.path.join(img_dir,image)
    out_ = os.path.join(output_dir,image)
    exec_shell(cmd.format(in_img=in_, width=rescale_width, height=rescale_height, out_img=out_))




if __name__ == "__main__":

  

  parser = argparse.ArgumentParser()
  parser.add_argument("img_dir", help="directory of the images.")
  parser.add_argument("-x", "--numx", help="number of x splits", type=int, default=1)
  parser.add_argument("-y", "--numy", help="number of y splits", type=int, default=1)
  parser.add_argument("-l", "--overlap", help="number of pixels to overlap spatially between splits", type=int, default=100)
  args = parser.parse_args()

  run(args.img_dir, args.numx, args.numy, args.overlap)

