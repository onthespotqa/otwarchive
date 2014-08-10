require 'spec_helper'

describe Work, "Validations" do
  # see lib/collectible_spec for collection n-related tests

  it "creates a minimally work" do
    create(:work).should be_valid
  end

  context "create_stat_counter" do
    it "creates a stat counter for that work id" do
      expect {
        @work = build(:work)
        @work.save!
      }.to change{ StatCounter.all.count }.by(1)
      StatCounter.where(:work_id => @work.id).should exist
    end
  end

  context "invalid title" do
    it { build(:work, title: nil).should be_invalid }

    let(:too_short) {ArchiveConfig.TITLE_MIN - 1}
    it "cannot be shorter than ArchiveConfig.TITLE_MIN" do
      build(:work, title: Faker::Lorem.characters(too_short)).should be_invalid
    end

    let(:too_long) {ArchiveConfig.TITLE_MAX + 1}
    it "cannot be longer than ArchiveConfig.TITLE_MAX" do
      build(:work, title: Faker::Lorem.characters(too_long)).should be_invalid
    end
  end

  context "clean_and_validate_title" do
    before do
      ArchiveConfig.TITLE_MIN = 10
    end

    it "strips out leading spaces from the title" do
      @work = create(:work, title: "    Has Leading Spaces")
      @work.reload
      @work.title.should == "Has Leading Spaces"
    end

    let(:too_short) {ArchiveConfig.TITLE_MIN - 1}
    it "errors if the title without leading spaces is shorter than #{ArchiveConfig.TITLE_MIN}" do
      expect { create(:work, title: "     #{too_short}")}.to raise_error(ActiveRecord::RecordInvalid,"Validation failed: Title must be at least #{ArchiveConfig.TITLE_MIN} characters long without leading spaces.")
    end

  end

  context "invalid notes" do
    it "cannot be longer than ArchiveConfig.NOTES_MAX" do
      too_long = (ArchiveConfig.NOTES_MAX + 10)
      build(:work, notes: Faker::Lorem.characters(too_long)).should be_invalid
    end
  end

  context "invalid summary" do
    it "cannot be longer than ArchiveConfig.NOTES_MAX" do
      too_long = (ArchiveConfig.SUMMARY_MAX + 10)
      build(:work, summary: Faker::Lorem.characters(too_long)).should be_invalid
    end
  end

  context "invalid endnotes" do
    let(:too_long) {ArchiveConfig.NOTES_MAX + 1}
    it "cannot be longer than ArchiveConfig.NOTES_MAX" do
      build(:work, endnotes: Faker::Lorem.characters(too_long)).should be_invalid
    end
  end

  context "validate authors" do

    xit "does not save an invalid pseud with *" do
      @work = Work.new(attributes_for(:work, authors: ["*pseud*"]))
      @work.save.should be_false
      @work.errors[:base].should include["These pseuds are invalid: *pseud*"]
    end

    it "does not save if author is blank" do
      @work = build(:no_authors)
      @work.save.should be_false
      @work.errors[:base].should include "Work must have at least one author."
    end
  end

  context "#clean_and_validate_title" do
    before do
      ArchiveConfig.TITLE_MIN = 5  #Current setting is 1, this code would never be executed with existing settings
    end

    it "strips out leading spaces from the title" do
      @work = create(:work, title: "    Has Leading Spaces")
      @work.clean_and_validate_title.should == "has leading spaces"
      @work.reload
      @work.title.should == "Has Leading Spaces"
    end

    let(:too_short) {ArchiveConfig.TITLE_MIN - 1}
    it "errors if the title without leading spaces is shorter than #{ArchiveConfig.TITLE_MIN}" do
      @work = build(:work, title: "     #{too_short}")
      @work.clean_and_validate_title.should be_false
      @work.errors[:base].should include("Title must be at least #{ArchiveConfig.TITLE_MIN} characters long without leading spaces.")
    end

  end

  context "#validate_published_at" do

    let(:published_in_past) {build(:published_in_past)}
    let(:past_publication_date) {published_in_past.first_chapter.published_at}
    it "returns nil if first_chapters published_at date is in the past" do
      published_in_past.save!
      published_in_past.validate_published_at.should == nil
      published_in_past.save
      published_in_past.first_chapter.published_at.should == past_publication_date
    end

    let(:published_date) { build(:work) }
    it "returns today if the first_chapter's date is empty" do
      published_in_past.save!
      published_date.validate_published_at.should == Date.today
      published_date.save
      published_date.first_chapter.published_at.should == Date.today
    end

    let(:published_in_future) {build(:published_in_future)}
    it "returns false if the first_chapter's published_at date is in the future" do
      published_in_future.validate_published_at.should be_false
      published_in_future.errors[:base].should include "Publication date can't be in the future."
    end
  end

  describe "#set_revised_at" do

    context "date provided" do

      before :each do
        @work = build(:published_in_past)
      end

      it "sets the revised_at date to today" do
        @work.set_revised_at(@work.first_chapter.published_at.to_date)
        @work.save
        @work.revised_at.to_date.should == Date.today
      end
    end

    context "chapters.maximum('published_at') is not today" do

      before :each do
        @work = build(:published_in_past)
      end

      it "sets the revised_at date to the chapters published_at date" do
        @work.set_revised_at(@work.first_chapter.published_at.to_date)
        @work.save!
        @work.revised_at.to_date.should == @work.first_chapter.published_at
      end

      it "sets the revised_at date to today if a work attribute is updated" do
        @work.update_attributes(:title => "Revised")
        @work.revised_at.to_date.should == Date.today
      end


    end

    context "date is nil" do

      before :each do
        @work = build(:work)
      end

      it "revised_at date is today" do
        @work.set_revised_at(nil)
        @work.save
        @work.revised_at.to_date.should == Date.today
      end
    end

    context "chapter is added" do

      let(:work) {create(:published_in_past)}
      let(:chapter) {build(:chapter, work: work)}
      it "should equal the new chapters published_at date" do
        chapter.save
        work.revised_at.to_date.should == chapter.published_at
        work.published_at.to_date.should == work.first_chapter.published_at
      end

      it "still has the published_at date of the first chapter if another chapter is added" do
        create(:chapter, work: work)
        work.revised_at.to_date.should == Date.today
        work.published_at.to_date.should == work.first_chapter.published_at
      end
    end

  end

  describe "#ensure_revised_at" do
    it "is set to today" do
      @work = build(:work)
      @work.save
      @work.revised_at.to_date.should == Date.today
    end
  end
    
end
