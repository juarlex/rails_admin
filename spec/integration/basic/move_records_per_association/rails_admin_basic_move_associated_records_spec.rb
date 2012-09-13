require 'spec_helper'

describe "RailsAdmin Basic Move Records Per Association" do
  subject { page }

  describe "Move records from has_many association" do
    before(:each) do
      @team1   = FactoryGirl.create :team
      @team2   = FactoryGirl.create :team

      5.times { @team1.players << FactoryGirl.create(:player) }

      @team1.save
    end

    it "should move associated objects" do
      @team1.players.size.should eql(5)

      page.driver.put move_records_per_association_path(:model_name => "team", :id => @team1.id), :association_name => 'players', :new_id => @team2.id
      page.driver.status_code.should eql(200)

      @team1.players.size.should eql(0)
      @team2.players.size.should eql(5)
    end

    it "should not process invalid entities" do
      page.driver.put move_records_per_association_path(:model_name => "team", :id => @team1.id), :association_name => 'players', :new_id => 'b'
      page.driver.status_code.should eql(404)

      page.driver.put move_records_per_association_path(:model_name => "team", :id => @team1.id), :association_name => 'players', :new_id => 1000
      page.driver.status_code.should eql(302)
    end

    it "should not execute non association methods" do
      page.driver.put move_records_per_association_path(:model_name => "team", :id => @team1.id), :association_name => 'destroy', :new_id => @team2.id
      page.driver.status_code.should eql(403)
    end

    it "should raise NotFound" do
      page.driver.put move_records_per_association_path(:model_name => "team", :id => 1000), :association_name => 'destroy', :new_id => @team2.id
      page.driver.status_code.should eql(404)
    end
  end

end
