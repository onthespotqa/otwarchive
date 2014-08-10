require 'spec_helper'

describe Work do

  #Tests callbacks and validations

  it { should callback(:create_stat_counter).after(:create)}
  it { should callback(:validate_authors).before(:save)}
  it { should callback(:clean_and_validate_title).before(:save)}
  it { should callback(:validate_published_at).before(:save)}
  it { should callback(:validate_published_at).before(:save)}

  describe "before_save callbacks" do
    context "#create_stat_counter" do
      it "creates a stat counter for that work id" do
        expect {
          @work = build(:work)
          @work.save!
        }.to change{ StatCounter.all.count }.by(1)
        StatCounter.where(:work_id => @work.id).should exist
      end
    end


    describe "#post_first_chapter" do
      let(:work) {build(:work)}
      it "posts the first chapter" do
         work.save
         work.update_attributes(:posted => true)
         work.posted.should be_true
         work.chapters.first.should exist
         work.chapters.first.position.should == 1
      end
    end

    describe "#set_word_count" do
      context "new single chapter work" do
        let(:work) {build(:work, chapter_attributes: {content: Faker::Lorem.sentence(25)})}
        it "equals the total works in the chapter" do
          work.save
          work.set_word_count.should == 25
        end
      end
    end

  end



end