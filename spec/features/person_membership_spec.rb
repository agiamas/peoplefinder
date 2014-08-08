require 'rails_helper'

feature "Person maintenance" do
  before do
    log_in_as 'test.user@digital.justice.gov.uk'
  end

  scenario 'Creating a person and making them the leader of a group' do
    group = create(:group, name: 'Digital Justice')
    visit new_person_path
    fill_in 'Surname', with: person_attributes[:surname]
    fill_in 'Job title', with: 'Head Honcho'
    select('Digital Justice', from: 'Team')
    check('Leader')
    click_button "Create person"

    membership = Person.last.memberships.last
    expect(membership.role).to eql('Head Honcho')
    expect(membership.group).to eql(group)
    expect(membership.leader?).to be true
  end

  scenario 'Clicking the add another role link', js: true do
    javascript_log_in
    visit new_person_path

    click_link('Add another role')
    expect(page).to have_selector('#memberships .membership', count: 2)

    click_link('remove', match: :first)
    expect(page).to have_selector('#memberships .membership', count: 1)
  end

  scenario 'Removing a group' do
    group = create(:group, name: 'Digital Justice')
    person = create(:person, person_attributes)
    person.memberships.create(group: group)

    visit edit_person_path(person)
    click_link('remove')

    expect(page).to have_content("Removed Marco Polo from Digital Justice")
    expect(person.reload.memberships).to be_empty
    expect(current_path).to eql(edit_person_path(person))
  end
end