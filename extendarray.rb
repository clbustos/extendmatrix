class Array
	def Array.random(len, min = 0, max = len)
		Array.new(len) { min + rand(max - min + 1) }
	end
	
	def nslice(n)
		return [] if n == 0
		lq = []
		len = self.size
		partNumber = (Float(len) / n).ceil
		ndiff = n - (partNumber * n - len) 
		(0...ndiff).each {|i|	lq << self.slice(i * partNumber...(i + 1) * partNumber)}
		(ndiff...n).each {|i| lq << self.slice(i * (partNumber - 1) + ndiff...(i + 1) * (partNumber - 1) + ndiff)} 
		lq
	end
end
