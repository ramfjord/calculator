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

$atoms = [ Fixnum, Symbol ].to_set

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
		return exp if Expression.atom?(exp)
		raise "invalid expression class: #{exp.class}"
	end

	def self.atom?(exp)
		$atoms.include?(exp.class)
	end

	def unary?
		@properties.include?(:unary)
	end
	
	def binary?
		@properties.include?(:binary)
	end

	def num?
		e1_num = Expression.atom?(@e1) ? @e1.is_a?(Fixnum) : @e1.num?
		return e1_num if unary?
		
		e2_num = Expression.atom?(@e2) ? @e2.is_a?(Fixnum) : @e2.num?
		e1_num && e2_num
	end

	def to_s
		# TODO fix with new atom leaves format
		return @e1.to_s if self.atom?
		return "(#{@op} #{@e1})" if self.unary?
		return "(#{@e1} #{@op} #{@e2})"
	end

	def resolve
		if num?
			e1 = Expression.atom?(@e1) ? @e1 : @e1.resolve
			return e1.send @op if unary?

			e2 = Expression.atom?(@e2) ? @e2 : @e2.resolve
			return e1.send @op, e2
		end
		raise "I don't know how to resolve things with variables yet :("
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
