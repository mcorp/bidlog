require 'rails_helper'

RSpec.describe BidBusiness, type: :model do
  fixtures :bids, :users
  subject { described_class.new(bid, user, params) }

  let(:user) { users(:owner) }
  let(:bid) { bids(:bid1) }
  let(:params) { {} }

  context 'methods' do
    it '#invite_or_notify dont create new object' do
      u = users(:bidder2)
      send_count = ActionMailer::Base.deliveries.count
      expect(subject.invite_or_notify(u, :bid_updated_notify)).to eq u.id
      expect(ActionMailer::Base.deliveries.count).to eq(send_count + 1)
    end

    it '#invite_or_notify create new user, inviting!' do
      u = User.new(email: 'nonexistingemail@email.com')
      expect(subject).to receive(:bid_invite).with(u).and_return(u)
      expect(User).to receive(:find_by).with(email: u.email).and_return(nil)
      subject.invite_or_notify(u, :notifier)
    end
  end

  context 'saving' do
    let(:bid) do 
      b = Bid.new(obs: 'teste')
      b.bidders << User.new(email: 'um_email@teste.com')
      b.bidders << users(:bidder_extra)
      b
    end

    before do
      User.delete_all(email: 'um_email@teste.com')
    end

    it 'save' do
      sent_count = ActionMailer::Base.deliveries.count
      expect(User.where(email: 'um_email@teste.com').count).to eq 0

      expect(subject.save).to be true
      expect(subject.bid.bidders.count).to be 2
      expect(ActionMailer::Base.deliveries.count).to be(sent_count + 2)
      expect(User.where(email: 'um_email@teste.com').count).to eq 1
    end
  end
end