# A recursive data structure contains an expression, an operator, and another expression
class Expression
	attr_accessor :e1			# expression 1
	attr_accessor :op			# operator
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
		!@op.nil? && @e2.nil?
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
			unary = false
			case operator
			when '+'
				@op = :+
			when '-'
				@op = :-
			when '/'
				@op = :/
			when '*'
				@op = :*
			when '^'
				@op = :^
			when "sqrt" 
				@op = :sqrt
				unary = true
			when "log" 
				@op = :log
				unary = true
			else raise err_prefix + "invalid operator"
			end

			if exp1.is_a?(Expression)
				@e1 = exp1
			else
				begin
					@e1 = Expression.parse_atom(exp1)
				rescue
					raise err_prefix + "invalid first expression"
				end
			end

			if unary
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
