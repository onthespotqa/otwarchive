require 'spec_helper'

describe Work, 'Associations' do

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


end