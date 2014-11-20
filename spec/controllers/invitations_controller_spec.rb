require 'rails_helper'
RSpec.describe InvitationsController, type: :controller do
  let(:author) { create(:user) }
  let!(:invitation) { Invitation.new(create(:review, author: author)) }

  before do
    open_review_period
  end

  describe 'PUT update' do
    context 'with an authenticated session' do
      before do
        authenticate_as(author)
      end

      it 'redirects to the replies list' do
        put :update, id: invitation.id, invitation: { status: :accepted }
        expect(response).to redirect_to(replies_path)
      end

      it 'changes the invitation to accepted' do
        put :update, id: invitation.id, invitation: { status: :accepted }
        expect(invitation.reload.status).to eql(:accepted)
      end

      it 'changes the invitation to declined, but only when a reason is given' do
        put :update, id: invitation.id, invitation: { status: :declined }
        expect(invitation.reload.status).to eql(:no_response)

        put :update, id: invitation.id, invitation: { status: :declined, reason_declined: 'Busy pondering the meaning of life' }
        expect(invitation.reload.status).to eql(:declined)
      end

      it 'returns an error message is the status was invalid' do
        put :update, id: invitation.id, invitation: { status: :cheese_sandwich }
        expect(request.flash[:error]).to_not be_empty
      end
    end

    context 'without an authenticated session' do
      it 'returns 403 forbidden' do
        put :update, id: invitation.id
        expect(response).to be_forbidden
      end
    end
  end
end