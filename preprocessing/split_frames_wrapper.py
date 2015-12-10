import os
from multiprocessing import Pool
from split_frames import run #numx, numy

import pdb


def run_wrapper(args):
	# name, x, y, overlap
	output = run(args[0],args[1],args[2],args[3],output_dir_base=args[4],doresize=args[5])
	print output
	output = tuple(output)
	return output


if __name__ == "__main__":


	output_dir_resize = '/cvgl/group/UAV_data/5-splits-b'
	output_dir_noresize = '/cvgl/group/UAV_data/5-splits-b-noresize'

	with open("split_frames_todo.txt","rb") as f:
		lines = f.readlines()

	to_map = []
	for line in lines:
		name, split_geo, overlap = line.strip().split()
		y = int(split_geo[1])
		x = int(split_geo[3])
		overlap = int(overlap)
		to_map.append((name,x,y,overlap,output_dir_resize,True))
		to_map.append((name,x,y,overlap,output_dir_noresize,False))




	pool = Pool(processes=6)
	output = pool.map(run_wrapper,to_map)
	pool.close()
	pool.join()

	"""
	with open("split_frames_rescaling.txt","wb") as f:
		for line in output:
			for l in line:
				f.write(l+"\n")
	"""
	# run('nexus4k-10-07-13pu_seq-a','nexus4k-10-07-13pu')
