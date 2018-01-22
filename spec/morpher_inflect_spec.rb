# encoding: utf-8
require File.dirname(__FILE__) + '/spec_helper.rb'

describe MorpherInflect do
  let(:parsed_response) {
    {
        "Р" => "рубина",
        "Д" => "рубину",
        "В" => "рубин",
        "Т" => "рубином",
        "П" => "рубине",
        "множественное" => {
          "И" => "рубины",
          "Р" => "рубинов",
          "Д" => "рубинам",
          "В" => "рубины",
          "Т" => "рубинами",
          "П" => "рубинах"
        }
      }
    }
  let(:sample_inflection) { %w(рубин рубина рубину рубин рубином рубине) }
  let(:sample_dumb_inflection) { %w(рубин рубин рубин рубин рубин рубин) }
  let(:inflector) { mock('MorpherInflect::Inflection') }
  let(:response_code) { 200 }
  let(:response) { mock('HTTParty::Response', code: response_code, parsed_response: parsed_response) }

  before(:each) do
    MorpherInflect::clear_cache
    inflector.stub!(:get).and_return(response)
    MorpherInflect::Inflection.stub!(:new).and_return(inflector)
  end

  it "should return an array of inflections when webservice returns an array" do
    MorpherInflect.inflections("рубин").should == sample_inflection
  end

  context "when webservice returns an error string" do
    let(:parsed_response) { {"code"=>5, "message"=>"Не найдено русских слов."} }
    let(:response_code) { 496 }
    it "should return an array filled with identical strings" do
      MorpherInflect.inflections("рубин").should == sample_dumb_inflection
    end
  end

  it "should return an array filled with identical strings of original word when webservice does not return anything meaningful or throws an exception" do
    inflector.stub!(:get).and_raise(Errno::ECONNREFUSED)
    MorpherInflect.inflections("рубин").should == sample_dumb_inflection
  end

  context "with caching" do
    it "should cache successful lookups" do
      MorpherInflect::Inflection.should_receive(:new).once.and_return(inflector)

      2.times { MorpherInflect.inflections("рубин") }
    end

    context "on unseccussful lookups" do
      let(:response_code) { 496 }
      it "should NOT cache result" do
        MorpherInflect::Inflection.should_receive(:new).twice.and_return(inflector)
        2.times { MorpherInflect.inflections("рубин") }
      end
    end

    it "should allow to clear cache" do
      MorpherInflect::Inflection.should_receive(:new).twice.and_return(inflector)

      MorpherInflect.inflections("рубин")
      MorpherInflect.clear_cache
      MorpherInflect.inflections("рубин")
    end
  end
end
