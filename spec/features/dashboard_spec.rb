require 'rails_helper'

feature 'Dashboard navigation' do
  let(:me) { create(:user) }
  let(:token) { me.tokens.create }

  scenario 'As Alice - manages people but does not receive feedback' do
    create(:user, manager: me)
    visit token_url(token)

    expect(page).not_to have_text(your_feedback)
    expect(page).to have_text(direct_reports_feedback)
    expect(page).to have_link(feedback_requests, href: replies_path)

    expect(page).to have_text('You have one direct report')
  end

  scenario 'As Alice - when the review period is closed', closed_review_period: true do
    create(:user, manager: me)
    visit token_url(token)

    expect(page).not_to have_css('ul#tab_navigation')
  end

  scenario 'As Bob - manages people and receives feedback' do
    create(:user, manager: me)
    me.update_attributes(manager: create(:user))
    visit token_url(token)

    expect(page).not_to have_link(your_feedback)
    expect(page).to have_link(direct_reports_feedback)
    expect(page).to have_link(feedback_requests)

    click_link(feedback_requests)
    expect(page).to have_link(your_feedback)
    expect(page).not_to have_link(feedback_requests)
  end

  scenario 'As Bob - when the review period is closed', closed_review_period: true do
    create(:user, manager: me)
    me.update_attributes(manager: create(:user))
    visit token_url(token)

    within('ul#tab_navigation') do
      expect(page).to have_text(your_feedback)
      expect(page).to have_link(direct_reports_feedback)
      expect(page).not_to have_text(feedback_requests)
    end
  end

  scenario 'As Charlie - receives feedback but does not manage people', closed_review_period: true do
    me.update_attributes(manager: create(:user))
    create(:review, subject: me)
    visit token_url(token)

    expect(page).not_to have_css('ul#tab_navigation')
  end

  scenario 'As Danny - only gives feedback' do
    me.update_attributes(participant: false)
    token = create(:review).tokens.create
    visit token_url(token)

    expect(page).not_to have_text(your_feedback)
    expect(page).not_to have_text(direct_reports_feedback)
    expect(page).not_to have_text(feedback_requests)
  end

  def your_feedback
    'Your feedback'
  end

  def direct_reports_feedback
    'Your direct reports'
  end

  def feedback_requests
    'Feedback requests'
  end
end