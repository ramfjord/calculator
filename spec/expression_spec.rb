require File.dirname(__FILE__) + '/../Expression'

describe Expression do
	describe "binary expressions: " do
		before(:each) do
			@e1 = 5
			@op = '/'
			@e2 = :a
		end

		it "should create a binary expression with Fixnums and Symbols" do
			lambda{e = Expression.new(@e1, @op, @e2)}.should_not raise_error
		end

		it "should create a binary expression with other expressions" do
			e = Expression.new(@e1, @op, @e2)
			e2 = Expression.new(5, "-", 56)
			lambda{e3 = Expression.new(e, "*", e2)}.should_not raise_error
		end

		it "shold not create binary expression with invalid operators" do
			lambda{Expression.new(@e1, '#', @e2)}.should raise_error
		end
	end

	describe "unary expressions:" do
		it "should create unary expressions with correct operators" do
			e = Expression.new(5, 'sin', nil)
			e.should be_unary
		end

		it "should not create unary expressions with incorrect operators" do
			#e = Expression.new(@e1, '+', nil)
			lambda{Expression.new(5, '+', nil)}.should raise_error
		end
	end

	describe "methods:" do
		before(:each) do
			@e1 = Expression.new(5, "+", 3)
			@e2 = Expression.new(@e1, "-", 6)
			@e3 = Expression.new(@e1, "/", @e2)
			@e1ans = 8
			@e2ans = 2
		end

		describe "to_s:" do
			it "should work" do
				@e3.to_s.should == "(5 + 3) / ((5 + 3) - 6)"
			end

			it "should work with logs" do
				e4 = Expression.new(@e3, "log", 2)
				e4.to_s.should == "log_2 ((5 + 3) / ((5 + 3) - 6))"
			end
		end

		describe "sanitize_s:" do
			it "should work with binary operators" do
				Expression.sanitize_s("5+3	 -4*3").should == "5 + 3 - 4 * 3"
			end

			it "should work with unary operators" do
				Expression.sanitize_s("sin		53 cos100").should == "sin 53 cos 100"
			end
		end

		describe "add_parens:" do 
			it "should work on purely unary expressions" do
				Expression.add_parens("sin cos tan x").should == "sin (cos (tan x))"
			end

			it "should work on purely binary expressions" do
				Expression.add_parens("a + b * c - 3 ^ 5 * 3").should == "a + ((b * c) - ((3 ^ 5) * 3))"
			end

			it "should work with the following" do
				# this didn't used to work, because it woulnd't condense 5 and x^2 after it read the
				# :+ in
				Expression.add_parens("5*x^2 + 3*x").should == "(5 * (x ^ 2)) + (3 * x)"
			end

			it "should work on hybrid binary/unary expressions" do
				Expression.add_parens(
					"a + b * c - 3 ^ 5 * sin 30 ^ 5"
				).should == 
					"a + ((b * c) - ((3 ^ 5) * (sin (30 ^ 5))))"
			end
		end

		describe "from_s:" do
			it "should work with flat expressions" do
				Expression.from_s("5 + 3").to_s.should == @e1.to_s
			end

			it "should work with deep expressions with correct parentheses" do
				Expression.from_s("(5 + 3) / ((5 + 3) - 6)").to_s.should == @e3.to_s
			end

			it "should infer parentheses with the order of operations" do
				Expression.from_s("4 + 5 * 3").to_s.should == "4 + (5 * 3)"
				Expression.from_s("4 * 5 + 3").to_s.should == "(4 * 5) + 3"
			end
		end

		it "should be able to resolve numeric expressions 1 level deep" do
			@e1.resolve.should == @e1ans
		end

		it "should be able to resolve numeric expressions multiple levels deep" do
			@e2.resolve.should == @e2ans
		end

		describe "simplify_base" do
			describe "with flat expressions" do 
				it "should simplify x + 0 to x" do
					Expression.from_s("0 + x").simplify_base.to_s.should == "x"
				end

				it "should simplify x - 0 to x" do
					Expression.from_s("x - 0").simplify_base.to_s.should == "x"
				end

				it "should simplify x * 0 to 0" do
					Expression.from_s("0 * x").simplify_base.to_s.should == "0"
				end

				it "should simplify x * 1 to x" do
					Expression.from_s("1 * x").simplify_base.to_s.should == "x"
				end

				it "should simplify x / 1 to x" do
					Expression.from_s("x / 1").simplify_base.to_s.should == "x"
				end

				it "should simplify 0 / x to 0" do
					Expression.from_s("0 / x").simplify_base.to_s.should == "0"
				end

				it "should simplify x ^ 1 to x" do
					Expression.from_s("x ^ 1").simplify_base.to_s.should == "x"
				end

				it "should simplify x ^ 0 to 1" do
					Expression.from_s("x ^ 0").simplify_base.to_s.should == "1"
				end
			end
			describe "with recursive expressions" do
				it "should work" do
					Expression.from_s("0*x + 22^4 * 0 + y^0 * y^1").simplify_base.to_s.should == "y"
				end
			end
		end
	end
end
