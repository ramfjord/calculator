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

	describe "resolution:" do
		before(:each) do
			@e1 = Expression.new(5, "+", 3)
			@e2 = Expression.new(@e1, "-", 6)
			@e1ans = 8
			@e2ans = 2
		end

		it "should be able to resolve numeric expressions 1 level deep" do
			@e1.resolve.should == @e1ans
		end

		it "should be able to resolve numeric expressions multiple levels deep" do
			@e2.resolve.should == @e2ans
		end
	end
end
