import Image, ImageDraw
import itertools
import random
import pdb
import os

defaultwidth = 1
colors = ["#FF00FF",
          "#FF0000",
          "#FF8000",
          "#FFD100",
          "#008000",
          "#0080FF",
          "#0000FF",
          "#000080",
          "#800080"]

color_label_map = {'Pedestrian':colors[0], 'Biker':colors[1], 
'Skater':colors[2], 'Cart':colors[3], 'Car':colors[4],
'Bus':colors[5]}

def highlight_box(image, box, color = colors[0], width = defaultwidth,
    font = None):
    """
    Highlights the bounding box on the given image.
    """
    draw = ImageDraw.Draw(image)
    if not box.occluded:
        width = width * 2
    for i in range(width):
        draw.rectangle((box.xmin + i, box.ymin + i, box.xmax - i, box.ymax - i),
                       outline=color)
    if font:
        ypos = box.ymin
        label = box.label
        size = draw.textsize(label, font = font)
        xpos = max(box.xmin - size[0] - 3, 0)

        draw.text((xpos, ypos+1), label,
                  fill="black", font=font)
        draw.text((xpos+1, ypos+1), label,
                  fill="black", font=font)
        draw.text((xpos+1, ypos), label,
                  fill="black", font=font)
        draw.text((xpos, ypos-1), label,
                  fill="black", font=font)
        draw.text((xpos-1, ypos-1), label,
                  fill="black", font=font)
        draw.text((xpos-1, ypos), label,
                  fill="black", font=font)

        draw.text((xpos, ypos), label,
                  fill="white", font=font)
        ypos += size[1] + 3
    return image

def highlight_boxes(image, boxes, colors = colors, width = defaultwidth,
    font = None):
    """
    Highlights an iterable of boxes.
    """
    for box, color in zip(boxes, itertools.cycle(colors)):
        highlight_box(image, box, color, width, font)
    return image

def highlight_path(images, path, color = colors[0], width = defaultwidth,
    font = None):
    """
    Highlights a path across many images. The images must be indexable
    by the frame. Produces a generator.
    """
    print "Visualize path of length {0}".format(len(path))
    for box in path:
        try:
            lost = box.lost
        except:
            lost = False
        image = images[box.frame]
        if not lost:
            highlight_box(image, box, color, width, font)
        yield image, box.frame

def highlight_paths(images, paths, colors = colors, width = defaultwidth, font = None, cycle=False, framesroot = "./"):
    """
    Highlights multiple paths across many images. The images must be indexable
    by the frame. Produces a generator.
    """

    print "Visualize {0} paths".format(len(paths))

    boxmap = {}
    if cycle:
        paths = zip(paths, itertools.cycle(colors))
    else:
        paths_tmp = []
        for path in paths:
            if len(path) > 0 and path[0].label in color_label_map:
                paths_tmp.append((path, color_label_map[path[0].label]))
            else:
                paths_tmp.append((path, colors[6]))
        paths = paths_tmp


    for path, color in paths:

        for box in path:
            if box.frame not in boxmap:
                boxmap[box.frame] = [(box, color)]
            else:
                boxmap[box.frame].append((box, color))

    for frame, boxes in sorted(boxmap.items()):
        im_path = os.path.join(framesroot, images[frame])
        im = Image.open(im_path)

        for box, color in boxes:
            try:
                lost = box.lost
            except:
                lost = False
            if not lost:
                highlight_box(im, box, color, width, font)
        yield im, frame

def save(images, output):
    """
    Saves images produced by the path iterators.
    """
    for image, frame in images:
        image.save(output(frame))
