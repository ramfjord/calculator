require 'set'

# TODO, how to represent distributive property: a(b+c) = ab + ac
$operations = { 
	:- => { :properties => [ :binary, :associative ].to_set,								:order => 5 },
	:+ => { :properties => [ :binary, :associative, :commutative ].to_set,	:order => 5 },
	:* => { :properties => [ :binary, :associative, :commutative ].to_set,  :order => 3 },
	:/ => { :properties => [ :binary, :associative ].to_set,                :order => 3 },
	:^ => { :properties => [ :binary ].to_set,															:order => 1 },
	:root => { :properties => [ :binary ].to_set,														:order => 1 },
	:log => { :properties => [ :binary ].to_set,														:order => 2 },
	:sin => { :properties => [ :unary ].to_set,															:order => 2 },
	:cos => { :properties => [ :unary ].to_set,															:order => 2 },
	:tan => { :properties => [ :unary ].to_set,															:order => 2 },
	:cosec => { :properties => [ :unary ].to_set,														:order => 2 },
	:sec => { :properties => [ :unary ].to_set,															:order => 2 },
	:cot => { :properties => [ :unary ].to_set,															:order => 2 },
}

	


# A recursive data structure contains an expression, an operator, and another expression
class Expression
	attr_accessor :e1			# expression 1
	attr_accessor :op			# operator
	attr_accessor :properties
	attr_accessor :e2			# expression 2

	def initialize *args
		case args.size
		when 1
			init_atom *args
		when 3
			init_exp *args
		else
			raise "invalid number of arguments for Expression constructor"
		end
	end

	def self.parse_atom(exp)
		return exp if exp.is_a?(Fixnum) || exp.is_a?(Symbol)
		raise "invalid expression class: #{exp.class}"
	end

	def atom?
		@op.nil? && @e2.nil?
	end

	def unary?
		@properties.include?(:unary)
	end

	def num?
		return @e1.is_a?(Fixnum) if self.atom?
		return @e1.num? if self.unary?
		@e1.num? && @e2.num?
	end

	def to_s
		return @e1.to_s if self.atom?
		return "(#{@op} #{@e1})" if self.unary?
		return "(#{@e1} #{@op} #{@e2})"
	end

	private

	def init_atom(exp)
		@e1 = Expression.parse_atom(exp)
		@op = nil
		@e2 = nil
	end

	def init_exp(exp1, operator, exp2)
		err_prefix = "Expression constructor: "
		if operator.nil? && exp2.nil?
			@e1 = Expression.parse_atom(exp1)
		else
			raise err_prefix + "invalid operation" if $operations[operator.to_sym].nil?
			@op = operator.to_sym
			@properties = $operations[@op][:properties]

			if exp1.is_a?(Expression)
				@e1 = exp1
			else
				begin
					@e1 = Expression.parse_atom(exp1)
				rescue
					raise err_prefix + "invalid first expression"
				end
			end

			if @properties.include?(:unary)
				@e2 = nil
			else
				if exp2.is_a?(Expression)
					@e2 = exp2
				else
					begin
						@e2 = Expression.parse_atom(exp2)
					rescue
						raise err_prefix + "invalid second expression"
					end
				end
			end
		end
	end
end
