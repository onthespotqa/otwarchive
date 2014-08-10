require 'spec_helper'

describe Work, "Preface" do
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

end
