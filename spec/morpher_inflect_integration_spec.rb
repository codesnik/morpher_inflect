# encoding: utf-8
require File.dirname(__FILE__) + '/spec_helper.rb'

describe MorpherInflect, "integration test" do
  # FIXME should we touch real service in test?
  if "".respond_to?(:encoding)

    it "should get inflections in correct encoding on ruby1.9" do
      inflections = MorpherInflect.inflections('тест')
      # real, not cached
      inflections[5].should == 'тесте'
      inflections[5].encoding.to_s.should == 'UTF-8'
    end

  end
end
