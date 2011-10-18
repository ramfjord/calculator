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
	:cot => { :properties => [ :unary ].to_set,															:order => 2 }
}

def is_op?(op)
	$operations[op.to_sym] == nil?
end

def op_prop?(op, prop)
	op_s = op.to_sym
	return (is_op? op) && ($operations[op_s][:properties].include? op_s)
end

def op_props(op)
	$operations[op.to_sym][:properties]
end


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

	def self.from_s(s)
		# do some preprocessing and pass to rec_from_s
		string_exp = s.gsub(/\s/, " ").squeeze(" ") # remove extraneous spaces

		# TODO preprocess log's into standard format
		return self.rec_from_s(string_exp)
	end

	# add parentheses to make clear the order of operations
	def self.add_parens(s)
		raise "method not implemented"
	end

	def self.is_atom(exp)
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
		e1_num = e1_atom? ? @e1.is_a?(Fixnum) : @e1.num?
		return e1_num if unary?
		
		e2_num = e2_atom? ? @e2.is_a?(Fixnum) : @e2.num?
		e1_num && e2_num
	end

	def to_s
		e1_s = e1_atom? ? @e1.to_s : "(#{@e1})"
		return "#{@op} #{e1_s}" if unary?

		e2_s = e2_atom? ? @e2.to_s : "(#{@e2})"
		return "#{e1_s} #{@op} #{e2_s}" unless @op == :log
		return "log_#{e2_s} #{e1_s}"
	end

	def resolve
		if num?
			e1 = e1_atom? ? @e1 : @e1.resolve
			return e1.send @op if unary?

			e2 = e2_atom? ? @e2 : @e2.resolve
			return e1.send @op, e2
		end
		raise "I don't know how to resolve things with variables yet :("
	end

	# private

	def e1_atom?
		Expression.atom?(@e1)
	end

	def e2_atom?
		Expression.atom?(@e2)
	end

	def init_atom(exp)
		@e1 = Expression.is_atom(exp)
		@op = nil
		@e2 = nil
	end

	def init_exp(exp1, operator, exp2)
		err_prefix = "Expression constructor: "
		if operator.nil? && exp2.nil?
			@e1 = Expression.is_atom(exp1)
		else
			raise err_prefix + "invalid operation" if $operations[operator.to_sym].nil?
			@op = operator.to_sym
			@properties = op_props @op

			if exp1.is_a?(Expression)
				@e1 = exp1
			else
				begin
					@e1 = Expression.is_atom(exp1)
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
						@e2 = Expression.is_atom(exp2)
					rescue
						raise err_prefix + "invalid second expression"
					end
				end
			end
		end
	end

	def self.rec_from_s(string_exp)
		e1 = nil
		e2 = nil
		op = nil
		unary = false
		rest = string_exp
		
		# process e1 / op (e1 could be op if it's unary, and if it's not we'll process the both)
		e1 = Expression.next_expression_chunk(string_exp)
		rest = string_exp[(e1.length + 1)..-1] # the rest of the string that's not e1 or the space

		# if e1 is in fact a unary operator
		if op_prop? e1, :unary
			unary = true
			op = e1.to_sym
		else 
			e1 = Expression.exp_from_chunk(e1)

			op = Expression.next_expression_chunk(rest).to_sym
			rest = rest[(op.length + 1)..-1]
		end

		# parse e2 (technically e1 for unary operators)
		e2 = Expression.exp_from_chunk(rest)

		if unary
			e1 = e2
			e2 = nil
		end

		Expression.new(e1, op, e2)
	end

	def self.exp_from_chunk(s)
		if s[0] == "("
			return Expression.rec_from_s(s[1...-1]) # remove outer parens
		else
			return Expression.parse_atom(s)
		end
	end

	# get's the next expression chunk from an expression string s, whether it be an atom or a expression inside balanced
	# parenthases
	def self.next_expression_chunk(s)
		if s[0] == "("
			# find the index of it's matching paren...
			match_i = 1
			paren_num = 1
			while paren_num > 0
				raise "you didn't balance your parentheses" if match_i > s.length

				paren_num -= 1 if s[match_i] == ")"
				paren_num += 1 if s[match_i] == "("
				match_i += 1
			end

			return s[0...match_i]
		end

		# this just get's everything up to the first space
		return s[/^[^ ]+/]
	end

	# parses one word of a string to return either a Fixnum or a Symbol, ignoring trailing chars (including parens)
	def self.parse_atom(s)
		# s.to_i returns 0 if s isn't an integer AND if s is "0", "00", ...
		if s.to_i == 0
			if s.squeeze("0") == "0"
				return 0
			else
				return s.to_sym
			end
		else
			return s.to_i
		end
	end
end
