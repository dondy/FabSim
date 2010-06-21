f ||= [ # factory map ] {{{
  %w\S T T B\,
  %w/T . . T/,
  %w\E . E B\, ]
w ||= [[0,0]] * f.length ** 2
b ||= [ nil ] * w.length
t ||= 0 #}}}
tick = Fiber.new{ # generate ticks on f {{{
  loop{ # to infinity and beyond!
    w.each_index{|i|
      if b[i] # workpiece is buffered {{{
	e,j = b[i]
	if j > 0
	  b[i] = [e,j-1]
	else
	  b[i] = nil
	  w[i] = e
	end #}}}
      else # workpiece not buffered {{{
	x,y = w[i]
	x,y = [[x,y-1],[x-1,y],
	       [x,y+1],[x+1,y]].find(lambda{w[i]}){|x,y|
	  0 <= x and x < f.length and 0 <= y and y < f[x].length and
	  f[x][y] != '.' and not w.include? [x,y] }
	case f[x][y]
	when 'T'; w[i] = [ x, y]
	when 'E'; w[i] = [ 0, 0]
	when 'B'; w[i] = [-1,-1]; b[i] = [[x,y],i]
	end #}}}
      end }
    Fiber.yield t += 1 } } #}}}
BEGIN{ require 'yaml' # Serialization {{{
  f,w,b,t = YAML.load File.open('FacSim.yaml') if File.exist? 'FacSim.yaml' }
END{ YAML.dump [f,w,b,t], File.open('FacSim.yaml','w') } #}}}
loop{ s = '' #TODO: replace CUI with a platform independent GUI {{{
  f.each_index{|x| s += "\n" 
    f[x].each_index{|y| s += (w.include?([x,y]) ? '[%s]':' %s ') % f[x][y] }
    b.each{|v,_| s += '+' if v and v[0] == x } }
  print s += "\n#{t}? "
  File.open('FacSim.log','a'){|fh| fh.puts s } # Logging...
  break if 0 >= gets.to_i.times{ tick.resume } } #}}}