require 'spec_helper'

describe Article::Page, dbscope: :example do
  let(:node) { create :article_node_page }

  describe "becomes_with_route" do
    subject(:item) { create :article_page, cur_node: node }
    it do
      page = Cms::Page.find(item.id).becomes_with_route
      expect(page.changed?).to be_falsey
    end
  end
end
