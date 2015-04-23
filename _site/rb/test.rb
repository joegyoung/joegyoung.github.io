
require 'gnuplot'


Gnuplot.open do |gp|
  Gnuplot::Plot.new( gp ) do |plot|
  

  plot.unset "border"
  plot.set "angles degrees"
  	plot.terminal "svg"
  	plot.output "curves.svg"
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

x = (0..300).collect { |v| rand(0..256) }
y = x.collect { |v| rand(0..256) }
z = x.collect { |v| rand(0..256) }
o = x.collect { |v| "#3ee4c2" }


plot.data << Gnuplot::DataSet.new( [x, y, z, o] ) do |ds|
      ds.with = "points pt 7 ps var lc rgb variable notitle"
      ds.using = '(xrgb($1,$2,$3)):(yrgb($1,$2,$3)):(1.+2.*rand(0)):(rgb($1,$2,$3))'
    end

    
  end
  
end




##
##
##
exit

def gnuplot(commands)
  IO.popen("gnuplot", "w") { |io| io.puts commands }
end

commands = %Q(
set terminal svg 
set output "curves.svg"
unset border
set angles degrees
set arrow 1 from 0, 0, 0 to 0, 1, 0 nohead back nofilled linetype -1 linecolor rgb "red"  linewidth 3.000
set arrow 2 from 0, 0, 0 to 0.866025, -0.5, 0 nohead back nofilled linetype -1 linecolor rgb "green"  linewidth 3.000
set arrow 3 from 0, 0, 0 to -0.866025, -0.5, 0 nohead back nofilled linetype -1 linecolor rgb "blue"  linewidth 3.000
set noxtics
set noytics
set noztics
set title "Both RGB color information and point size controlled by input" 
set lmargin  5
set bmargin  2
set rmargin  5
rgb(r,g,b) = int(r)*65536 + int(g)*256 + int(b)
xrgb(r,g,b) = (g-b)/255. * cos(30.)
yrgb(r,g,b) = r/255. - (g+b)/255. * sin(30.)
plot 'rgb_variable.dat' using (xrgb($1,$2,$3)):(yrgb($1,$2,$3)):(1.+2.*rand(0)):(rgb($1,$2,$3))      with points pt 7 ps var lc rgb variable notitle
)
gnuplot(commands)
