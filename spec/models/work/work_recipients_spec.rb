require 'spec_helper'

describe Work, "Recpients" do
  describe "new recipients virtual attribute", :pending do

    before(:each) do
      @author = create(:user)
      @recipient1 = create(:user)
      @recipient2 = create(:user)
      @recipient3 = create(:user)

      @fandom1 = create(:fandom)
      @chapter1 = create(:chapter)

      @work = Work.new(:title => "Title")
      @work.fandoms << @fandom1
      @work.authors = [@author.pseuds.first]
      @work.recipients = @recipient1.pseuds.first.name + "," + @recipient2.pseuds.first.name
      @work.chapters << @chapter1
    end

    it "should be the same as recipients when they are first added" do
      @work.new_recipients.should eq(@work.recipients)
    end

    it "should only contain the new recipients when more are added" do
      @work.recipients += "," + @recipient3.pseuds.first.name
      @work.new_recipients.should eq(@recipient3.pseuds.first.name)
    end

    it "should only contain the new recipient if replacing the previous recipient" do
      @work.recipients = @recipient3.pseuds.first.name
      @work.new_recipients.should eq(@recipient3.pseuds.first.name)
    end

    it "should be empty if one or more of the original recipients are removed" do
      @work.recipients = @recipient2.pseuds.first.name
      @work.new_recipients.should be_empty
    end

  end

end