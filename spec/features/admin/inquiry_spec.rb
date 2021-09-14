# frozen_string_literal: true

describe 'Admin::Inquiry', type: :feature do
  before { login(admin: true) }
  let!(:inquiry) { create(:inquiry) }
  let(:page_title) { find('#page_title') }

  describe '#index' do
    before { visit admin_inquiries_path }
    it 'should open the index page' do
      expect(page_title).to have_content('Inquiries')
      expect(page).to have_content(inquiry.referer)
      expect(page).to have_content('Edit')
      expect(page).not_to have_css('.delete_link')
    end
  end

  describe '#show' do
    before { visit admin_inquiry_path(inquiry) }
    it 'should open the show page' do
      expect(page_title).to have_content("Inquiry ##{inquiry.id}")
      expect(page).to have_content(inquiry.user.name)
      expect(page).to have_content(inquiry.body)
    end
  end

  describe '#update' do
    let(:new_admin_memo) { Faker::Lorem.paragraph }
    before do
      visit edit_admin_inquiry_path(inquiry)
      fill_in 'inquiry[admin_memo]', with: new_admin_memo
      click_on 'Update'
    end

    it 'should update the inquiry' do
      expect(page_title).to have_content("Inquiry ##{inquiry.id}")
      expect(current_path).to eq admin_inquiry_path(inquiry)
      expect(page).to have_content(new_admin_memo)
      expect(inquiry.reload.admin_memo).to eq new_admin_memo
    end
  end
end
