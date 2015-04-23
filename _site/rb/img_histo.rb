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

def calc_hist( object )
	dim = 1
    sizes = [20]
    ranges = [[0, 255]]
    h2 = OpenCV::CvHistogram.new(dim, sizes, OpenCV::CV_HIST_ARRAY, ranges, true).calc_hist!(object.split)

    hist = []
	(0..19).each do |number|
		#puts h2[number]
		hist << h2[number].to_i
	end
	return hist
end




def histdisplay(histogram)


 height = 15
 white = OpenCV::IplImage.new(40, height)
 white.set!(OpenCV::CvScalar.new(255,255,255,0))

 scalar_color = OpenCV::CvScalar.new(0,0,0,0)

 (0..19).each do |i|
	 lineh = (( histogram[i] * height ) / 10000) + 1
	 lineh =  height - lineh
	 white.rectangle! OpenCV::CvPoint.new(i * 2 ,height), OpenCV::CvPoint.new((i* 2)+2,lineh), :color => scalar_color, :thickness => -1
 end

 return white

end








histo = calc_hist( object )


white = histdisplay( histo)

white.save("../media/histogram.jpg")












