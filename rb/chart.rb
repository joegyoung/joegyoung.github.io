require 'graphr'
require 'chunky_png'
require 'pp'


# In this simple example we don't even have a "real" graph
# just an Array with the links. The optional third element 
# of a link is link information. The nodes in this graph are 
# implicit in the links. If we had additional nodes that were
# not linked we would supply them in an array as 2nd parameter.
#links = [[:start, 1, "*"], [1, 1, "a"], [1, 2, "~a"], [2, :stop, "*"]]


links = [

["Finish product", "Make Money", ""],
["Make Money", "Profit", ""],

]


dgp = DotGraphPrinter.new(links)

# We specialize the printer to change the shape of nodes
# based on their names.
dgp.node_shaper = proc do |n|
  ["",""].include?(n.to_s) ? "doublecircle" : "box"
end

# We can also set the attributes on individual nodes and edges.
# These settings override the default shapers and labelers.
#dgp.set_node_attributes("lola", :shape => "ellipse")

#dgp.set_node_attributes("Finish product", :color => "darkorange")




# Add URL link from node (this only work in some output formats?)
# Note the extra quotes needed!
dgp.set_node_attributes(2, :URL => '"node2.html"')

# And now output to files
dgp.write_to_file("/tmp/chart.png", "png")  # Generate png file

image = ChunkyPNG::Image.from_file('/tmp/chart.png')


(0..image.dimension.width-1).each do |x|
  (0..image.dimension.height-1).each do |y|
		if ChunkyPNG::Color.to_truecolor_bytes(image[x,y]) == [255, 255, 255] 
		    image[x,y] = ChunkyPNG::Color.rgba(0, 0, 0,0)
		end
  end
end

image.save('../media/chart.png')