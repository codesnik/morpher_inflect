# encoding: utf-8
require File.dirname(__FILE__) + '/spec_helper.rb'

describe MorpherInflect do
  before(:all) do
    @sample_inflection_response = ["рубина", "рубину", "рубин", "рубином", "рубине"]
    @sample_inflection = ["рубин"] + @sample_inflection_response
  end
  
  before(:each) do
    @inflection = mock(:inflection)
    MorpherInflect::clear_cache
  end

  it "should return an array of inflections when webservice returns an array" do
    @inflection.stub!(:get).and_return(@sample_inflection_response)
    MorpherInflect::Inflection.should_receive(:new).and_return(@inflection)
    MorpherInflect.inflections("рубин").should == @sample_inflection
  end

  it "should return an array filled with identical strings when webservice returns an error string" do
    @inflection.stub!(:get).and_return("Программа не может просклонять это словосочетание.")
    MorpherInflect::Inflection.should_receive(:new).and_return(@inflection)
    MorpherInflect.inflections("рубин").should == %w(рубин рубин рубин рубин рубин рубин)
  end

  it "should return an array filled with identical strings of original word when webservice does not return anything meaningful or throws an exception" do
    @inflection.stub!(:get).and_return(nil)
    MorpherInflect::Inflection.should_receive(:new).and_return(@inflection)
    MorpherInflect.inflections("рубин").should == %w(рубин рубин рубин рубин рубин рубин)
  end
end

describe MorpherInflect, "with caching" do
  before(:each) do
    @inflection = mock(:inflection)
    MorpherInflect::clear_cache
  end

  it "should cache successful lookups" do
    sample = ["рубина", "рубину", "рубин", "рубином", "рубине"]
    @inflection.stub!(:get).and_return(sample)
    MorpherInflect::Inflection.should_receive(:new).once.and_return(@inflection)
    
    2.times { MorpherInflect.inflections("рубин") }
  end
  
  it "should NOT cache unseccussful lookups" do
    sample = nil
    @inflection.stub!(:get).and_return(sample)
    MorpherInflect::Inflection.should_receive(:new).twice.and_return(@inflection)
    
    2.times { MorpherInflect.inflections("рубин") }
  end
  
  it "should allow to clear cache" do
    sample = "рубин"
    @inflection.stub!(:get).and_return(sample)
    MorpherInflect::Inflection.should_receive(:new).twice.and_return(@inflection)
    
    MorpherInflect.inflections("рубин")
    MorpherInflect.clear_cache
    MorpherInflect.inflections("рубин")
  end
end

describe MorpherInflect::Inflection do
  before(:all) do
    @sample_answer = {
      "ArrayOfString"=>{"string"=>["рубина", "рубину", "рубин", "рубином", "рубине"]}
    }
    @sample_inflection = ["рубина", "рубину", "рубин", "рубином", "рубине"]
  end
  
  it "should get inflections for a word" do
    MorpherInflect::Inflection.should_receive(:get).and_return(@sample_answer)
    MorpherInflect::Inflection.new.get("рубин").should == @sample_inflection
  end

end
