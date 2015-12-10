import os
from multiprocessing import Pool
from split_frames import rescale

import pdb


def run_wrapper(args):
	# name, x, y, overlap
	rescale(args[0],args[1],args[2])


if __name__ == "__main__":

	video_dir = "/cvgl/group/UAV_data/5-crop-b"
	output_dir = "/cvgl/group/UAV_data/5-crop-rescale-2"
	batch = 100


	#videos = ['bytes4k-09-25-12pu']
	#videos = ['deathCircle4k-10-5-11a30u']
	#videos = ['hyang4k-04-10-3lsp-1u']
	videos = os.listdir("/cvgl/group/UAV_data/5-crop-b")



	to_map = []
	for video in videos:
		vid_ = os.path.join(video_dir,video)
		out_ = os.path.join(output_dir,video)
		if os.path.exists(out_) and len(os.listdir(out_))>300:
			continue
		frames = os.listdir(vid_)
		for i in range(0,len(frames),batch):
			group = frames[i:i+batch]
			to_map.append((vid_,out_,group))


	pool = Pool(processes=15)
	pool.map(run_wrapper,to_map)
	pool.close()
	pool.join()


	# run('nexus4k-10-07-13pu_seq-a','nexus4k-10-07-13pu')
