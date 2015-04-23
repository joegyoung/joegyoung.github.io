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
require 'yaml'

require 'gnuplot'



include OpenCV

##### Main #####


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
			htmlcolor = Color::RGB.new( i.position[2],i.position[1],i.position[0] ).html
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





centroids =  extract_colors(object)













Gnuplot.open do |gp|
  Gnuplot::Plot.new( gp ) do |plot|
  

  plot.unset "border"
  plot.set "angles degrees"
  	plot.terminal "svg  size 400,220"
  	plot.output "../media/colorplot.svg"
    plot.set "arrow 1 from 0, 0, 0 to 0, 1, 0 nohead back nofilled linetype -1 linecolor rgb 'red'  linewidth 3.000"
plot.set "arrow 2 from 0, 0, 0 to 0.866025, -0.5, 0 nohead back nofilled linetype -1 linecolor rgb 'green'  linewidth 3.000"
plot.set "arrow 3 from 0, 0, 0 to -0.866025, -0.5, 0 nohead back nofilled linetype -1 linecolor rgb 'blue'  linewidth 3.000"
plot.set "noxtics"
plot.set "noytics"
plot.set "noztics"

plot.set 'title "Both RGB color information and point size controlled by input" '
plot.set "lmargin  5"
plot.set "bmargin  2"
plot.set "rmargin  5"
plot.arbitrary_lines << "rgb(r,g,b) = int(r)*65536 + int(g)*256 + int(b)"
plot.arbitrary_lines << "xrgb(r,g,b) = (g-b)/255. * cos(30.)"
plot.arbitrary_lines << "yrgb(r,g,b) = r/255. - (g+b)/255. * sin(30.)"
#plot.arbitrary_lines << "plot 'rgb_variable.dat' using (xrgb($1,$2,$3)):(yrgb($1,$2,$3)):(2):(rgb($1,$2,$3)) with points pt 7 ps var lc rgb variable notitle"

#x = (0..300).collect { |v| rand(0..256) }
#y = x.collect { |v| rand(0..256) }
#z = x.collect { |v| rand(0..256) }
#o = x.collect { |v| "#3ee4c2" }

x = []
y =[]
z = []


centroids.each do |point|

x << point[0]
y << point[1]
z << point[2]
end

#o = x.collect { |v| "#3ee4c2" }



plot.data << Gnuplot::DataSet.new( [x, y, z] ) do |ds|
      ds.with = "points pt 7 ps var lc rgb variable notitle"
      ds.using = '(xrgb($1,$2,$3)):(yrgb($1,$2,$3)):(1.+2.*rand(0)):(rgb($1,$2,$3))'
    end

    
  end
  
end






#puts "Background #{centroids[0][:htmlcolor]}"
















