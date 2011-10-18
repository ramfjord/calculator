#require File.dirname(__FILE__) + '/spec_helper'
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

		describe "from_s:" do
			it "should work with flat expressions" do
				Expression.from_s("5 + 3").to_s.should == @e1.to_s
			end

			it "should work with deep expressions with correct parentheses" do
				Expression.from_s("(5 + 3) / ((5 + 3) - 6)").to_s.should == @e3.to_s
			end

			it "should infer parentheses with the order of operations" do
				Expression.from_s("4 + 5 * 3").to_s.should == "4 + (5 * 3)"
				Expression.from_s("4 * 5 + 3").to_s.should == "(4 * 5) * 3"
			end
		end

		it "should be able to resolve numeric expressions 1 level deep" do
			@e1.resolve.should == @e1ans
		end

		it "should be able to resolve numeric expressions multiple levels deep" do
			@e2.resolve.should == @e2ans
		end
	end
end
