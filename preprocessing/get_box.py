#!/usr/bin/env python2
#
# File: get_box.py
#
# Created: Thursday, October 15 2015 by rejuvyesh <mail@rejuvyesh.com>
# License: GNU GPL 3 <http://www.gnu.org/copyleft/gpl.html>
#

import sys
import os
from glob import glob
import numpy as np
import subprocess
from extract_valid_track import extract_track

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


def run(argv1,argv2):
  #Expects argv1 and argv2 to not have a trailing /
  img_dir_base = '/cvgl/group/UAV_data/4-stabilized-lb/'
  out_dir_base = '/cvgl/group/UAV_data/5-crop-b/'


  img_dir = os.path.join(img_dir_base,argv1)
  out_dir = os.path.join(out_dir_base,argv2)

  if not os.path.exists(out_dir):
    os.makedirs(out_dir)
  in_imgs = sorted(glob('{0}/*.jpg'.format(img_dir)))
  
  in_imgs_list = img_dir +'/%08d.jpg'
  out_imgs = out_dir + '/%08d.jpg'
  bboxes = extract_track([in_imgs_list % i for i in range(len(in_imgs))], bb_format='ulwh')
  
  ux = np.mean(bboxes[:,0])
  uy = np.mean(bboxes[:,1]) #max
  width = np.mean(bboxes[:,2])#min
  height = np.mean(bboxes[:,3])
  #ux = 73
  #uy = 143
  #width = 3659
  #height = 1931
  print('{0},{1},{2},{3}'.format(ux, uy, width, height))
  
  cmd = "convert {in_img} -crop {w}x{h}+{ux}+{uy} {out_img}"
  for i in range(len(in_imgs)):
    exec_shell(cmd.format(in_img=(in_imgs_list % i), 
                          w=width, h=height, ux=ux, uy=uy, 
                          out_img=(out_imgs %i)))

if __name__ == "__main__":
  run(sys.argv[1],sys.argv[2])  
