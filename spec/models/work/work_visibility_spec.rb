require 'spec_helper'

describe Work, "VISIBILITY" do
  describe "#visible" do

    context "restricted" do

      let(:restricted_work) {create(:restricted_work)}
      it "is false if there is not a current user" do
        expect(restricted_work.visible).to be_false
      end

      let(:user) {create(:user)}
      let(:restricted_work) {create(:restricted_work)}
      xit "is true if there is not a current user" do
        puts user.inspect
        expect(restricted_work.visible(user)).to be_true
      end
    end

    context "hidden_by_admin" do
      let(:hidden_by_admin) {create(:hidden_by_admin)}
      it "is false if there is not a current user" do
        expect(hidden_by_admin.visible).to be_false
      end

      it "is true if the current_user is an admin"

      let(:hidden_by_admin) {create(:work)}
      xit "is true if the current_user is the author" do
        user = hidden_by_admin.authors.first
        expect(hidden_by_admin.visible(user)).to be_true
      end
    end
  end
end