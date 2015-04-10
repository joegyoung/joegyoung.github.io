#!/usr/bin/env ruby
# -*- mode: ruby; coding: utf-8 -*-

# A Demo Ruby/OpenCV Implementation of SURF
# See https://code.ros.org/trac/opencv/browser/tags/2.3.1/opencv/samples/c/find_obj.cpp
require 'opencv'
require 'benchmark'
require 'pp'
require 'ruby_vor'
include OpenCV


##### Main #####
puts 'This program demonstrated the use of the SURF Detector and Descriptor using'
puts 'brute force matching on planar objects.'
puts 'Usage:'
puts "ruby #{__FILE__} <object_filename> <scene_filename>, default is box.png and box_in_scene.png"
puts

object_filename = (ARGV.size == 1) ? ARGV[0] : 'images/lena-256x256.jpg'


object, image = nil, nil
begin
  #object = IplImage.load(object_filename, CV_LOAD_IMAGE_GRAYSCALE)
  object = IplImage.load(object_filename)
  object_gray = object.BGR2GRAY
  #object2 = CvMat.new(object.width, object.height, :cv8u, 1).clear!
  object2 = IplImage.new(object.width, object.height)
  object2.set!(CvScalar.new(0x00, 0x00, 0x00, 0))

 white = IplImage.new(object.width, object.height)
  white.set!(CvScalar.new(0xff, 0xff, 0xff, 0))

  #object2 = IplImage.load(object_filename)
  object3 = IplImage.load(object_filename)




rescue
  puts "Can not load #{object_filename} and/or #{scene_filename}"
  puts "Usage: ruby #{__FILE__} [<object_filename> <scene_filename>]"
  exit
end


#pp object.size.width * object.size.height

#pp object[50480].to_a

#white = CvScalar.new(0xff, 0xff, 0xff, 0)

#pp ( white - object[50480] ).to_a


data = '/usr/local/Cellar/opencv/2.4.9/share/OpenCV/haarcascades/haarcascade_frontalface_alt.xml'
detector = CvHaarClassifierCascade::load(data)

he = object.height 
wi = object.width

dectect = detector.detect_objects(object,{:min_size => CvSize.new(he * 0.20,wi * 0.20)})
  dectect.each { |rect|
    object2.rectangle! rect.top_left, rect.bottom_right, :color => CvScalar.new(0x00, 0x0, 0xff, 0), :thickness => 2

increase_size = 100;
pt1 = CvPoint.new(rect.top_left.x - increase_size,rect.top_left.y- increase_size)
pt2 = CvPoint.new(rect.bottom_right.x + increase_size,rect.bottom_right.y + increase_size)


#puts "[#{rect.top_left.x}, #{rect.top_left.y}], [#{rect.bottom_right.x}, #{rect.bottom_right.y}]"


 object2.rectangle! pt1, pt2, :color => CvScalar.new(0xff, 0x0, 0xff, 0), :thickness => 1




  }

#pp dectect.count






param = CvSURFParams.new(800)

#pp Module.constants 
#pp Algorithm.methods

object_keypoints, object_descriptors = nil, nil


  object_keypoints, object_descriptors = object_gray.extract_surf(param)
  puts "Object Descriptors: #{object_descriptors.size}"

object_keypoints.to_a.each do |point|
  object2.circle!(point.pt, 1, :color => CvColor::Red, :thickness => -1)
end


opts = {}

##
points = []



###
###
###

      max_x = 0
      min_x = Float::MAX
      max_y = 0
      min_y = Float::MAX
      pmax_x = 0
      pmin_x = Float::MAX
      pmax_y = 0
      pmin_y = Float::MAX


###
### pull points
### 


object_keypoints.to_a.each do |point|
  points << RubyVor::Point.new(point.pt.x, point.pt.y)
end
#pp points[0]


comp = RubyVor::VDDT::Computation.from_points(points)
 #pp comp.voronoi_diagram_raw






      comp.points.each do |point|
        max_x = point.x if point.x > max_x
        min_x = point.x if point.x < min_x
        max_y = point.y if point.y > max_y
        min_y = point.y if point.y < min_y
        pmax_x = point.x if point.x > pmax_x
        pmin_x = point.x if point.x < pmin_x
        pmax_y = point.y if point.y > pmax_y
        pmin_y = point.y if point.y < pmin_y
      end
if opts[:voronoi_diagram]
comp.voronoi_diagram_raw.each do |item|
          if item.first == :v
            max_x = item[1] if item[1] > max_x
            min_x = item[1] if item[1] < min_x
            max_y = item[2] if item[2] > max_y
            min_y = item[2] if item[2] < min_y
          end
        end
end      

opts[:triangulation] = true
#opts[:voronoi_diagram] = true

      if opts[:triangulation]
        # Draw in the triangulation

        comp.delaunay_triangulation_raw.each do |triplet|

          for i in 0..2
            line = comp.points[triplet[i % 2 + 1]], comp.points[triplet[i & 6]]
   

  pt1 = CvPoint.new(line[0].x,line[0].y)
  pt2 = CvPoint.new(line[1].x,line[1].y)
  object2.line!(pt1, pt2, :color => CvColor::Gray,:thickness => 1)
          end
        end
      end

      if opts[:triangulation]

comp.points.each do |point|
  point =  CvPoint.new(point.x,point.y)
   object2.circle!(point, 1, :color => CvColor::Purple, :thickness => 4)
end


      end

if opts[:voronoi_diagram]
voronoi_vertices = []
        draw_lines = []
        draw_points = []
        line_functions = []

comp.voronoi_diagram_raw.each do |item|
          case item.first
          when :v
            # Draw a voronoi vertex
            v = RubyVor::Point.new(item[1], item[2])
            voronoi_vertices.push(v)
            draw_points << v
            #draw_points << CvPoint.new(item[1], item[2])
          when :l
            # :l a b c  --> ax + by = c
            a = item[1]
            b = item[2]
            c = item[3]
            line_functions.push({ :y => lambda{|x| (c - a * x) / b},
                                  :x => lambda{|y| (c - b * y) / a} })
            when :e
            if item[2] == -1 || item[3] == -1
              from_vertex = voronoi_vertices[item[2] == -1 ? item[3] : item[2]]
              
              next if from_vertex < RubyVor::Point.new(0,0)              

              if item[2] == -1
                inf_vertex = RubyVor::Point.new(0, line_functions[item[1]][:y][0])
                
              else
                inf_vertex = RubyVor::Point.new(max_x, line_functions[item[1]][:y][max_x])
              end
                line = [from_vertex,inf_vertex]
             # line = line_from_points(from_vertex, inf_vertex)
            else
              #line = line_from_points(voronoi_vertices[item[2]], voronoi_vertices[item[3]])
              line =  voronoi_vertices[item[2]],voronoi_vertices[item[3]]
            end

            draw_lines << line


          end
        end

line_color = CvScalar.new(0xff, 0xff, 0xff, 0);

draw_lines.each do |item|
  pt1 = CvPoint.new(item[0].x,item[0].y)
  pt2 = CvPoint.new(item[1].x,item[1].y)
  object2.line!(pt1, pt2, :color => line_color, :thickness => 1)
end
draw_points.each do |item|
  pt =  CvPoint.new(item.x,item.y)
  object2.circle!(pt, 1, :color => line_color, :thickness => 1)
end

end







##
pt1 = CvPoint.new(max_x,max_y)
pt2 = CvPoint.new(min_x,min_y)

line_color = CvScalar.new(0xff, 0xff, 0x00, 0);
 object2.rectangle! pt1, pt2, :color => line_color, :thickness => 1



##




#windows = GUI::Window.new('other')
#windows.show object
#GUI::wait_key




#object2 = object2.smooth(CV_BLUR,6,1,0,0)
object2_gray = object2.BGR2GRAY
object2_mask= object2_gray.in_range(0x01 , 0xFF)

invertis =  white.sub(object2)

invertis.copy(object3,object2_mask)

object2.copy(object3,object2_mask)


max = 100.0
val = max / 3.4
#object4 = CvMat.add_weighted(object, val / max, object3, 1.0 - val / max, 0)
object4 = CvMat.add_weighted(object, 0.5, object3, 0.5 , 0)



windows = GUI::Window.new('Object Correspond')
windows.show object4
GUI::wait_key



















def outside_bounding_box?(x,y,box)
  x1 = box[0]; x2 = box[2]
  y1 = box[1]; y2 = box[3]
  max_x = [x1, x2].max
  max_y = [y1, y2].max
  min_x = [x1, x1].min
  min_y = [y1, y2].min
  return x < min_x || x > max_x || y < min_y || y > max_y
end

def inside_bounding_box?(x,y,box)
     if outside_bounding_box?(x,y,box) == false
      return true
    else
      return false
    end
end

#pp inside_bounding_box?(xp,yp,[x1,y1,x2,y2])







def find_corners_of_sqaure(point1, point2)

x1 = point1.x  ;  y1 = point1.y;    #// First diagonal point
  x2 = point2.x  ;  y2 = point2.x ;    #// Second diagonal point

  xc = (x1 + x2)/2  ;  yc = (y1 + y2)/2  ;    #// Center point
  xd = (x1 - x2)/2  ;  yd = (y1 - y2)/2  ;    #// Half-diagonal

  x3 = xc - yd  ;  y3 = yc + xd;    #// Third corner
  x4 = xc + yd  ;  y4 = yc - xd;    #// Fourth corner

puts "[#{x3}, #{y3}], [#{x4}, #{y4}]"
end




exit
#####
object4 = IplImage.load(object_filename,0)
    dim = 1
    sizes = [20]
    ranges = [[0, 255]]
hist =  CvHistogram.new(dim, sizes, CV_HIST_ARRAY, ranges, true).calc_hist!([object4])

#hist.normalize!(100)

dim2 = dim - 1
sizes2 = sizes[0]- 1

(dim2..sizes2).each do |i|
puts "#{i} #{hist[i]}"
end

pp hist.min_max_value











