# -*- coding: utf-8 -*-
require 'spec_helper'

describe "User page", js: false do
  before do
    User.destroy_all
    @user = create( :user_with_account )
    @login_string = @user.alias
    @password = @user.account.password
  end

  subject { page }
  
  context "when not signed in" do
    before do
      visit user_path( @user )
    end
    
    #it { should have_content "Access denied" }
  end

  context "when signed in" do  
    before do 

      visit new_session_path
      fill_in 'login_name', with: @login_string
      fill_in 'password', with: @password
      click_button I18n.t( :login )

      visit user_path( @user )
    end
  
    it { should have_selector('h1', text: I18n.t( :about_myself ) ) }
    it { should have_selector('h1', text: I18n.t( :study_information ) ) }
    it { should have_selector('h1', text: I18n.t( :career_information ) ) }
    it { should have_selector('h1', text: I18n.t( :organizations ) ) }

    it { should have_selector('title', text: "Wingolfsplattform") }
  end 
end

