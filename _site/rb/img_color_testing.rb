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


object, object2 = nil, nil
begin

  object = OpenCV::IplImage.load(object_filename)

rescue
  puts "Can not load #{object_filename} "
  puts "Usage: ruby #{__FILE__} [<object_filename> ]"
  exit
end



object2 = object.resize(OpenCV::CvSize.new(object.width/3,object.height/3))

count = (object2.size.width * object2.size.height) - 1

counts = Hash.new 0

for n in (0..count)
  counts[object2[n].to_a] += 1
end

data = []

#pp counts.select{|k,v| v > 20}.sort_by {|k,v| -v }[0..4] #.map(&:first)

counts.select{|k,v| v > 1}.sort_by {|k,v| -v }.map(&:first).each do |color|
	data << [color[0],color[1],color[2],color[3]]
end


kmeans = KMeans.new(data, :centroids => 8 )


x = 30
xx = 30
total_nodes = kmeans.nodes.count
total_centroids = kmeans.centroids.count
width_of_pict = object.width
height_of_pict = object.height - 30
print_width = (width_of_pict / total_centroids)


kmeans.centroids.sort! { |a, b|  a.position <=> b.position }

kmeans.centroids.sort! { |a, b|  kmeans.nodes.count{|v| v.closest_centroid.position == b.position} <=> kmeans.nodes.count{|v| v.closest_centroid.position == a.position} }

kmeans.centroids.each do |i|

color = Color::RGB.new( i.position[0],i.position[1],i.position[2] )
pp color.html
end


=begin
#Details
print "0:"; pp kmeans.centroids[0].position
print "1:"; pp kmeans.centroids[1].position
print "2:"; pp kmeans.centroids[2].position
print "3:"; pp kmeans.centroids[3].position
print "4:"; pp kmeans.centroids[4].position
print "5:"; pp kmeans.centroids[5].position
print "6:"; pp kmeans.centroids[6].position
print "7:"; pp kmeans.centroids[7].position
print "node"; pp kmeans.nodes[1].closest_centroid.position

print "0:"; pp kmeans.nodes.count { |element| element.closest_centroid.position == kmeans.centroids[0].position }
print "1:"; pp kmeans.nodes.count { |element| element.closest_centroid.position == kmeans.centroids[1].position }
print "2:"; pp kmeans.nodes.count { |element| element.closest_centroid.position == kmeans.centroids[2].position }
print "3:"; pp kmeans.nodes.count { |element| element.closest_centroid.position == kmeans.centroids[3].position }
print "4:"; pp kmeans.nodes.count { |element| element.closest_centroid.position == kmeans.centroids[4].position }
print "5:"; pp kmeans.nodes.count { |element| element.closest_centroid.position == kmeans.centroids[5].position }
print "6:"; pp kmeans.nodes.count { |element| element.closest_centroid.position == kmeans.centroids[6].position }
print "7:"; pp kmeans.nodes.count { |element| element.closest_centroid.position == kmeans.centroids[7].position }
=end



kmeans.centroids.each do |i|
	nodenumber =  kmeans.nodes.count{|v| v.closest_centroid.position == i.position}
	percent = nodenumber.to_f / total_nodes.to_f
	if percent != 0 
	  color_width = (width_of_pict - 60) * ( percent )
	  puts "#{nodenumber} / #{total_nodes} --> #{(percent *100).to_i } and is #{color_width.to_i}"

	  scalar_color = OpenCV::CvScalar.new(i.position[0],i.position[1],i.position[2],i.position[3])
	  #object.circle!( OpenCV::CvPoint.new(xx,80) , 1, :color => scalar_color, :thickness => 30) xx += print_width;
	  object.rectangle! OpenCV::CvPoint.new(x,height_of_pict), OpenCV::CvPoint.new(x+color_width.to_i,height_of_pict+16), :color => scalar_color, :thickness => -1
	  x += color_width;
	  

	end
end


scalar_color = OpenCV::CvScalar.new(0,0,0,0)
object.rectangle! OpenCV::CvPoint.new(29,height_of_pict), OpenCV::CvPoint.new(width_of_pict-29,height_of_pict+16), :color => scalar_color, :thickness => 1

windows = OpenCV::GUI::Window.new('Image')
windows.show object
OpenCV::GUI::wait_key























