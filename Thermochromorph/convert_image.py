# Code adapted from https://gist.github.com/llwyd/6051c0d1b78ecf2e6954bde7ac09d63c
# import PIL
from PIL import Image, ImageCms
import os
import sys

path_prefix = './'

def rgb_to_cmyk(rgb_image_path, output_path):
	img = Image.open(rgb_image_path)

	# Available via https://www.adobe.com/support/downloads/iccprofiles/iccprofiles_win.html
	fp = os.path.join(path_prefix, 'icc/icc/')
	rgb_icc = fp+"RGB/" + 'AppleRGB.icc'
	cmyk_icc = fp+"CMYK/"+"WebCoatedSWOP2006Grade5.icc"

	im = ImageCms.profileToProfile(img, rgb_icc, cmyk_icc, renderingIntent=0, outputMode='CMYK')
	source = im.split()

	# create blank image and split the layers
	blank = Image.new("CMYK", im.size, (0,0,0,0))
	b_split = blank.split()

	# add the separate layers to the k layer
	c_out = Image.merge("CMYK",(b_split[0], b_split[1], b_split[2], source[0]))
	m_out = Image.merge("CMYK",(b_split[0], b_split[1], b_split[2], source[1]))
	y_out = Image.merge("CMYK",(b_split[0], b_split[1], b_split[2], source[2]))
	k_out = Image.merge("CMYK",(b_split[0], b_split[1], b_split[2], source[3]))

	out = Image.merge("CMYK",(source[0],  source[1], source[2], source[3]))

	# Colour versions
	white = (255,255,255)

	c_out_rgb = ImageCms.profileToProfile(c_out, cmyk_icc, rgb_icc, renderingIntent=0, outputMode='RGB')
	c_out_rgb = c_out_rgb.rotate(15, Image.BILINEAR, expand = 1, fillcolor = white)
	c_out_rgb.save(os.path.join(output_path, 'c_{}.png'.format(15)),'PNG',optimize=False)

	m_out_rgb = ImageCms.profileToProfile(m_out, cmyk_icc, rgb_icc, renderingIntent=0, outputMode='RGB')
	m_out_rgb = m_out_rgb.rotate(75, Image.BILINEAR, expand = 1, fillcolor = white)
	m_out_rgb.save(os.path.join(output_path,'m_{}.png'.format(75)),'PNG',optimize=False)

	y_out_rgb = ImageCms.profileToProfile(y_out, cmyk_icc, rgb_icc, renderingIntent=0, outputMode='RGB')
	y_out_rgb.save(os.path.join(output_path,'y_0.png'),'PNG',optimize=False)

	k_out_rgb = ImageCms.profileToProfile(k_out, cmyk_icc, rgb_icc, renderingIntent=0, outputMode='RGB')
	k_out_rgb = k_out_rgb.rotate(45, Image.BILINEAR, expand = 1, fillcolor = white)
	k_out_rgb.save(os.path.join(output_path,'k_{}.png'.format(45)),'PNG',optimize=False)

if __name__ == "__main__":

    # rgb_image_path = sys.argv[1]
    rgb_image_path = "img1.png"

    # Replace 'output_path' with the desired output path for the separate channels
    output_path = 'data/img1'

    # Call the function to convert and save the CMYK channels
    rgb_to_cmyk(os.path.join(path_prefix,rgb_image_path), os.path.join(path_prefix, output_path))

    rgb_image_path = "img2.png"

    # Replace 'output_path' with the desired output path for the separate channels
    output_path = 'data/img2'

    # Call the function to convert and save the CMYK channels
    rgb_to_cmyk(os.path.join(path_prefix,rgb_image_path), os.path.join(path_prefix, output_path))

