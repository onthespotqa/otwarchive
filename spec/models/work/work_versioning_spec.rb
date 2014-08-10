require 'spec_helper'

describe Work, "VERSIONS & REVISION DATES" do

  context "#validate_published_at" do

    let(:published_in_past) {build(:published_in_past)}
    let(:past_publication_date) {published_in_past.first_chapter.published_at}
    it "returns nil if first_chapters published_at date is in the past" do
      published_in_past.save!
      published_in_past.validate_published_at.should == nil
      published_in_past.save
      published_in_past.published_at.should == past_publication_date
    end

    let(:published_date) { build(:work) }
    it "returns today if the first_chapter's date is empty" do
      published_date.save
      published_date.published_at.should == Date.today
    end

    let(:published_in_future) {build(:published_in_future)}
    it "returns false if the first_chapter's published_at date is in the future" do
      published_in_future.validate_published_at.should be_false
      published_in_future.errors[:base].should include "Publication date can't be in the future."
    end
  end

  describe "#set_revised_at" do

    context "date provided" do

      let(:published_in_past) { build(:published_in_past) }
      it "sets the revised_at date to the passed in date" do
        published_in_past.set_revised_at(published_in_past.first_chapter.published_at)
        published_in_past.save
        published_in_past.revised_at.to_date.should == published_in_past.first_chapter.published_at
      end
    end

    context "chapters.maximum('published_at') is not today" do

      let(:published_in_past) { build(:published_in_past) }
      it "sets the revised_at date to the chapters published_at date" do
        published_in_past.set_revised_at(published_in_past.first_chapter.published_at)
        published_in_past.save
        published_in_past.revised_at.to_date.should == published_in_past.first_chapter.published_at
      end
    end

    context "date is nil" do

      let(:work) {build(:work)}
      it "revised_at date is today" do
        pending "requirements in code are vague"
        work.set_revised_at(nil)
        work.save
        work.revised_at.to_date.should == Date.today
      end

      let(:work) {build(:work)}
      it "sets the revised_at date to today if a work published in past attribute is updated" do
        pending "requirements in code are vague"
        work.title = "Revised"
        work.set_revised_at(nil)
        work.save
        work.revised_at.to_date.should == Date.today
      end
    end

  end

  describe "#set_revised_at_by_chapter" do
    context "chapter is added to the work" do

      let(:work) {create(:published_in_past)}
      let(:chapter) {build(:chapter, work: work, published_at: Date.today)}
      it "should equal the new chapters published_at date" do
        work.set_revised_at_by_chapter(chapter)
        work.set_revised_at(chapter.published_at)
        work.save
        work.revised_at.to_date.should == chapter.published_at
      end

      let(:work) {create(:published_in_past)}
      let(:chapter) {build(:chapter, work: work, published_at: Date.today)}
      it "still has the published_at date of the first chapter if another chapter is added" do
        work.set_revised_at_by_chapter(chapter)
        work.save
        work.revised_at.to_date.should == Date.today
        work.published_at.to_date.should == work.first_chapter.published_at
      end
    end
  end

  describe "#ensure_revised_at" do
    it "is set to today" do
      pending "requirements in code are vague"
      @work = build(:work)
      @work.save
      @work.revised_at.should == Date.today
    end
  end

  describe "#update_minor_version" do
    let(:work) {build(:work, minor_version: 2)}
    it "increments the minor_version by 1" do
      work.update_minor_version
      work.save
      expect(work.minor_version).to eq 3
    end
  end

  describe "#update_major_version" do
    let(:work) {build(:work, major_version: 1, minor_version: 2)}
    it "increments the major_version by 1" do
      work.update_major_version
      work.save
      expect(work.major_version).to eq 2
    end

    let(:work) {build(:work, major_version: 1, minor_version: 2)}
    it "resets the minor_version back to 0" do
      work.update_major_version
      work.save
      expect(work.minor_version).to eq 0
    end
  end

end