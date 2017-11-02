class Gws::Circular::TopicsController < ApplicationController
  include Gws::BaseFilter
  include Gws::CrudFilter

  model Gws::Circular::Topic

  before_action :set_item, only: [:show, :edit, :update, :delete, :destroy, :set_seen, :unset_seen, :toggle_seen]
  before_action :set_selected_items, only: [:destroy_all, :disable_all, :set_seen_all, :unset_seen_all, :download]

  private

  def fix_params
    { cur_user: @cur_user, cur_site: @cur_site }
  end

  def set_crumbs
    @crumbs << [I18n.t('modules.gws/circular'), gws_circular_topics_path]
  end

  public

  def show
    if @item.see_type == 'simple' && @item.unseen?(@cur_user)
      @item.set_seen(@cur_user).save
    end
    raise '403' unless @item.allowed?(:read, @cur_user, site: @cur_site)
    render
  end

  def set_seen
    raise '403' unless @item.unseen?(@cur_user)
    render_update @item.set_seen(@cur_user).update
  end

  def unset_seen
    raise '403' unless @item.seen?(@cur_user)
    render_update @item.unset_seen(@cur_user).update
  end

  def toggle_seen
    raise '403' unless @item.member?(@cur_user)
    render_update @item.toggle_seen(@cur_user).update
  end

  def set_seen_all
    @items.each{ |item| item.set_seen(@cur_user).save if item.unseen?(@cur_user) }
    render_destroy_all(false)
  end

  def unset_seen_all
    @items.each{ |item| item.unset_seen(@cur_user).save if item.seen?(@cur_user) }
    render_destroy_all(false)
  end

  def download
    raise '403' if @items.empty?

    csv = @items.
        order(updated: -1).
        to_csv.
        encode('SJIS', invalid: :replace, undef: :replace)

    send_data csv, filename: "circular_#{Time.zone.now.to_i}.csv"
  end
end
