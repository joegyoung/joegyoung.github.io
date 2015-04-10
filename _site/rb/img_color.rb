#!/usr/bin/env ruby
# -*- mode: ruby; coding: utf-8 -*-

# A Demo Ruby/OpenCV Implementation of SURF
# See https://code.ros.org/trac/opencv/browser/tags/2.3.1/opencv/samples/c/find_obj.cpp
require 'opencv'
#require 'benchmark'
require 'pp'
require 'ruby_vor'
require 'k_means'
require 'color'

include OpenCV

##### Main #####
puts 'I want the stupid color on this photo'

puts 'Usage:'
puts "ruby #{__FILE__} <object_filename> "
puts

object_filename = (ARGV.size == 1) ? ARGV[0] : 'images/lena-256x256.jpg'


object =  nil
begin
  object = OpenCV::IplImage.load(object_filename)
rescue
  puts "Can not load #{object_filename} "
  puts "Usage: ruby #{__FILE__} [<object_filename> ]"
  exit
end

#INPUT: opencv_IplImage
#OUTPUT: array with centroids and size in percent
def color_centroids(opencv_image)
	## --> Part 1
	data = extract_colors(opencv_image)
	## --> Part 2
	kmeans = KMeans.new(data, :centroids => 8 )
	## --> Sort KMeans
	kmeans.centroids.sort! { |a, b|  a.position <=> b.position }
	kmeans.centroids.sort! { |a, b|  kmeans.nodes.count{|v| v.closest_centroid.position == b.position} <=> kmeans.nodes.count{|v| v.closest_centroid.position == a.position} }
	## --> 
	centroids = []
	total_nodes = kmeans.nodes.count
	kmeans.centroids.each do |i|
		nodenumber =  kmeans.nodes.count{|v| v.closest_centroid.position == i.position}
		percent = nodenumber.to_f / total_nodes.to_f
		if percent != 0 
			htmlcolor = Color::RGB.new( i.position[0],i.position[1],i.position[2] ).html
			centroids << {:position => i.position, :percent => percent, :htmlcolor => htmlcolor}
		end
	end
	return centroids
end


def extract_colors(opencv_image)

	smaller_object, count, counts, data =  nil, nil, nil, nil
	## Make smaller image to scan
	smaller_object = opencv_image.resize(OpenCV::CvSize.new(opencv_image.width/3,opencv_image.height/3))

	## Get pixel size
	count = (smaller_object.size.width * smaller_object.size.height) - 1

	counts = Hash.new 0

	for n in (0..count)
	  counts[smaller_object[n].to_a] += 1
	end

	data = []

	counts.select{|k,v| v > 1}.sort_by {|k,v| -v }.map(&:first).each do |color|
		data << [color[0],color[1],color[2],color[3]]
	end

	return data

end





centroids =  color_centroids(object)

width_of_pict = object.width
height_of_pict = object.height - 30
x = 30


centroids.each do |center|

	#pp center[:position]
	#pp center[:percent]

	color_width = (width_of_pict - 60) * ( center[:percent] )
	scalar_color = OpenCV::CvScalar.new(center[:position][0],center[:position][1],center[:position][2],center[:position][3])
	object.rectangle! OpenCV::CvPoint.new(x,height_of_pict), OpenCV::CvPoint.new(x+color_width.to_i,height_of_pict+16), :color => scalar_color, :thickness => -1
	x += color_width;

end

	scalar_color = OpenCV::CvScalar.new(0,0,0,0)
	object.rectangle! OpenCV::CvPoint.new(29,height_of_pict), OpenCV::CvPoint.new(width_of_pict-29,height_of_pict+16), :color => scalar_color, :thickness => 1

	windows = OpenCV::GUI::Window.new('Image')

	windows.show object
	#OpenCV::GUI::wait_key






###


  color_overlay = IplImage.new(object.width, object.height)
  color_overlay.set!(CvScalar.new( 256, 256, 256,0))
  object4 = CvMat.add_weighted(object, 0.08, color_overlay, 0.92 , 0)

object4.save_image("../media/save.jpg")


	windows.show object4
	OpenCV::GUI::wait_key






