class Object
	def default_block(block)
		block ? lambda { |i| block.call(i) } : lambda {|i| i }
	end
end
