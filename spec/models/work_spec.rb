require 'spec_helper'

describe Work do
  # see lib/collectible_spec for collectio n-related tests

  it "creates a minimally work" do
    create(:work).should be_valid
  end


  describe "work_skin_allowed", :pending do
    context "public skin"

    context "private skin" do
      before :each do
        @skin_author = create(:user)
        @second_author = create(:user)
        @private_skin = create(:private_work_skin, author_id: @skin_author.id)
      end

      let(:work_author) {@skin_author}
      let(:work){build(:custom_work_skin, authors: [work_author.pseuds.first], work_skin_id: @private_skin.id)}
      it "can be used by the work skin author" do
        puts work_author.login
        puts work_author.pseuds.first.name
        work.save.should be_true
      end

      let(:work){build(:custom_work_skin, authors: [@second_author.pseuds.first], work_skin_id: @private_skin.id)}
      it "cannot be used by another user" do
        puts @skin_author.login
        puts @skin_author.pseuds.first.name
        puts @second_author.login
        puts @second_author.pseuds.first.name
        work.save.should be_false
         work.errors[:base].should include("You do not have permission to use that custom work stylesheet.")
      end
    end
  end

  #TODO: Move to a collection mailer spec
  it "should send an email when added to collection"

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
