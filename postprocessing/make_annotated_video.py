"""
Script to import annotation file and generate a folder of frames where each frame has the objects
annotated with the bounding boxes provided in the annotation file.


Each line in the annotations.txt file corresponds to an annotation.
Each line contains 10+ columns, separated by spaces. The definition of these columns are:

    1   Track ID. All rows with the same ID belong to the same path.
    2   xmin. The top left x-coordinate of the bounding box.
    3   ymin. The top left y-coordinate of the bounding box.
    4   xmax. The bottom right x-coordinate of the bounding box.
    5   ymax. The bottom right y-coordinate of the bounding box.
    6   frame. The frame that this annotation represents. 0 indexed. 
    7   lost. If 1, the annotation is outside of the view screen.
    8   occluded. If 1, the annotation is occluded.
    9   generated. If 1, the annotation was automatically interpolated.
    10  label. The label for this annotation, enclosed in quotation marks.
    11+ attributes. Each column after this is an attribute.

"""
from visualize import highlight_paths, save
import os, argparse, subprocess
import pdb



class box:
	def __init__(self,line):
		lsplit = line.strip().split()
		#ignore the attributes.
		b = [int(x) for x in lsplit[:9]]
		#trackid, xmin, ymin, xmax, ymax, frame, lost, occluded, generated = l9
		self.id = b[0]
		self.xmin = b[1]
		self.ymin = b[2]
		self.xmax = b[3]
		self.ymax = b[4]
		self.frame = b[5]
		self.lost = b[6]
		self.occluded = b[7]
		self.generated = b[8]
		self.label = str(lsplit[9].replace('"', ''))
	def __repr__(self):
		return ("({0},{1},{2},{3},{4},{5},{6},{7},{8},{9})".format(self.id, self.xmin,
			self.ymin, self.xmax, self.ymax, self.frame, self.lost, self.occluded,
			self.generated, self.label))





parser = argparse.ArgumentParser()
parser.add_argument("annotation_file", help="Path to the annotation file")
parser.add_argument("frames_folder", help="Path to the frames folder")
parser.add_argument("output_folder", help="Path to the output folder and video.")
args = parser.parse_args()


annotation_file = args.annotation_file
frames_folder = args.frames_folder
output_folder = args.output_folder.strip("/")
# annotation_file = "/cvgl/group/UAV_data/7-annotations/bookstore/video0/annotations.txt"
# frames_folder = "/cvgl/group/UAV_data/7-videos/bookstore/video0/frames"
# output = "test_video0"



paths = []
with open(annotation_file, "rb") as f:
	current_trackid = 0
	path = []
	for line in f:
		b = box(line)
		if b.id == current_trackid:
			path.append(b)
		else:
			paths.append(path)
			path = []
			current_trackid = b.id
	paths.append(path)

#sort the frames...
frames = sorted(os.listdir(frames_folder))
it = highlight_paths(frames, paths, font=None, cycle=False, framesroot = frames_folder)

try:
	os.makedirs(output_folder)
except:
	pass

#pdb.set_trace()

save(it, lambda x: "{0}/{1}.jpg".format(output_folder,x))
cmd = "avconv -f image2 -r 29.97 -i {0}/%d.jpg -vcodec mjpeg -qscale 5 {1}"
videoname = '{0}.mov'.format(output_folder)

cmd_ = cmd.format(output_folder,videoname)
print cmd_
subprocess.call(cmd_, shell=True)


