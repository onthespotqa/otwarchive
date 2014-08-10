require 'spec_helper'

describe Work, 'Active Record Validations' do
  context "Relationships" do
    it { should  have_many(:creatorships)}
    it { should  have_many(:pseuds).through(:creatorships) }
    it { should  have_many(:users).through(:pseuds) }
    it { should  have_many(:external_creatorships).as(:creation).dependent(:destroy).with_foreign_key(:creation) }  #TODO: test inverse_of and as
    it { should  have_many(:archivists).through(:external_creatorships)}
    it { should  have_many(:external_author_names).through(:external_creatorships)}
    it { should  have_many(:chapters).conditions("work_id IS NOT NULL")}
    it { should  have_many(:serial_works).dependent(:destroy)}
    it { should  have_many(:series).through(:serial_works)}
    it { should  have_many(:related_works).as(:parent)} #TODO test :as
    it { should  have_many(:approved_related_works).class_name("RelatedWork").conditions("reciprocal = 1")}
    it { should  have_many(:parent_work_relationships).class_name("RelatedWork").dependent(:destroy)}
    it { should  have_many(:children).through(:related_works)}
    it { should  have_many(:approved_children).through(:approved_related_works)}
    it { should  have_many(:gifts).dependent(:destroy)}
    it { should  accept_nested_attributes_for(:gifts).allow_destroy(true)}
    it { should  have_many(:subscriptions).as(:subscribable).dependent(:destroy)}
    it { should  have_many(:challenge_assignments) }
    it { should  have_many(:challenge_claims)}
    it { should  accept_nested_attributes_for(:challenge_claims).allow_destroy(true) }
    it { should  have_many(:filter_taggings) }
    it { should  have_many(:filters).through(:filter_taggings) }
    it { should have_many(:direct_filter_taggings).class_name("FilterTagging").conditions("inherited = 0")}
    it { should have_many(:direct_filters).through(:direct_filter_taggings) }
    it { should have_many(:taggings).dependent(:destroy)}
    it { should have_many(:ratings).through(:taggings).conditions("tags.type = 'Rating'")}
    it { should have_many(:categories).through(:taggings).conditions("tags.type = 'Category'")}
    it { should have_many(:warnings).through(:taggings).conditions("tags.type = 'Warning'")}
    it { should have_many(:fandoms).through(:taggings).conditions("tags.type = 'Fandom'")}
    it { should have_many(:relationships).through(:taggings).conditions("tags.type = 'Relationship'")}
    it { should have_many(:characters).through(:taggings).conditions("tags.type = 'Character'")}
    it { should have_many(:freeforms).through(:taggings).conditions("tags.type = 'Freeform'")}
    it { should have_many(:total_comments).class_name("Comment").through(:chapters)}
    it { should have_many(:kudos).dependent(:destroy) }
    it { should belong_to(:language) }
    it { should belong_to(:work_skin) }
    it { should have_many(:work_links).dependent(:destroy) }
    it { should have_one(:stat_counter).dependent(:destroy) }
  end

  context "callbacks" do
    it { should callback(:create_stat_counter).after(:create)}
    it { should callback(:validate_authors).before(:save)}
    it { should callback(:clean_and_validate_title).before(:save)}
    it { should callback(:validate_published_at).before(:save)}
    it { should callback(:validate_published_at).before(:save)}
  end

end