#require File.dirname(__FILE__) + '/spec_helper'
require File.dirname(__FILE__) + '/../Expression'

describe Expression do
	describe "atoms: " do
		it "should create a atomic expression with a Fixnum" do
			e = Expression.new(5)
			e.should be_atom
		end

		it "should create a atomic expression with a Symbol" do
			e = Expression.new(:a)
			e.should be_atom
		end
	end

	describe "binary expressions: " do
		before(:each) do
			@e1 = 5
			@op = '/'
			@e2 = :a
		end

		it "should create a binary expression with Fixnums and Symbols" do
			e = Expression.new(@e1, @op, @e2)
			e.should_not be_atom
		end

		it "shold not create binary expression with invalid operators" do
			lambda{Expression.new(@e1, '#', @e2)}.should raise_error
		end
	end

	describe "unary expressions:" do
		it "should create unary expressions with correct operators" do
			e = Expression.new(5, 'sqrt', nil)
			e.should be_unary
		end

		it "should not create unary expressions with incorrect operators" do
			#e = Expression.new(@e1, '+', nil)
			lambda{Expression.new(5, '+', nil)}.should raise_error
		end
	end
end
