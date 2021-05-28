require 'spec_helper'

describe Article::Page, dbscope: :example do
  let(:node) { create :article_node_page }

  describe ".enum_csv" do
    let!(:item) { create :article_page, cur_node: node }
    subject do
      described_class.all.enum_csv(encoding: "UTF-8", form: nil, cur_user: cms_user, cur_site: cms_site, cur_node: node).to_a
    end

    context "usual case" do
      it do
        expect(subject.length).to eq 2
        expect(subject[0]).to include(described_class.t(:filename), described_class.t(:name), described_class.t(:body_part))
        expect(subject[1]).to include(item.basename, item.name)
      end
    end

    context "all references or arrays are set null" do
      before do
        # some functions are set nil to reference or array fields.
        # this causes "undefined method" error.
        item.set(
          layout_id: nil, body_layout_id: nil, form_id: nil, body_parts: nil, category_ids: nil, event_dates: nil,
          related_page_ids: nil, related_page_sort: nil, parent_crumb_urls: nil, contact_group_id: nil, group_ids: nil
        )
      end

      it do
        expect(subject.length).to eq 2
        expect(subject[0]).to include(described_class.t(:filename), described_class.t(:name), described_class.t(:body_part))
        expect(subject[1]).to include(item.basename, item.name)
      end
    end
  end
end
