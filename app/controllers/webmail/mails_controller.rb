class Webmail::MailsController < ApplicationController
  include Webmail::BaseFilter
  include Webmail::ImapFilter
  include Sns::CrudFilter

  model Webmail::Mail

  before_action :apply_filters, if: ->{ request.get? }
  before_action :set_mailbox
  before_action :select_mailbox
  before_action :set_item, only: [:show, :edit, :update, :delete, :destroy,
                                  :attachment, :download, :header_view, :source_view]
  after_action :expunge, only: [:move, :destroy, :destroy_all]

  private
    def set_crumbs
      @crumbs << [:'webmail.mail', { action: :index } ]
    end

    def apply_filters
      count = Webmail::Filter.user(@cur_user).enabled.map do |filter|
        filter.apply_recent
      end.inject(:+)

      flash[:notice] = t('webmail.notice.filter_applied', count: count) if count > 0
    end

    def set_mailbox
      @mailbox = params[:mailbox]
      @navi_mailboxes = true
    end

    def select_mailbox
      if request.get? || params[:action] =~ /copy|set_/
        @imap.conn.examine(@mailbox)
      else
        @imap.conn.select(@mailbox)
      end
    end

    def fix_params
      @imap.cache_key.merge(cur_user: @cur_user, sync: true, mailbox: @mailbox)
    end

    def set_item
      set_mailbox
      @item = @model.where(mailbox: @mailbox).imap_find params[:id]
      @item.attributes = fix_params
    end

    def set_destroy_items
    end

    def crud_redirect_url
      { action: :index }
    end

    def expunge
      @imap.conn.expunge
    end

  public
    def index
      @items = @model.
        where(mailbox: @mailbox).
        imap_search(params[:s]).
        page(params[:page]).
        per(50).
        imap_all
    end

    def show
      @item.set_seen if @item.unseen?
    end

    def attachment
      @item.attachments.each_with_index do |at, idx|
        next unless idx == params[:idx].to_i

        disposition = at.content_type.start_with?('image') ? :inline : :attachment
        return send_data at.read, filename: at.filename, content_type: at.content_type, disposition: disposition
      end

      raise '404'
    end

    def download
      data = @item.rfc822
      name = @item.subject + '.eml'
      send_data data, filename: name, content_type: 'message/rfc822', disposition: :attachment
    end

    def header_view
      data = @item.rfc822.sub(/(\r\n|\n){2}.*/m, '')
      render inline: ApplicationController.helpers.br(data), layout: false
    end

    def source_view
      data = @item.rfc822
      render inline: ApplicationController.helpers.br(data), layout: false
    end

    def set_seen
      change_flag(:set_seen)
    end

    def unset_seen
      change_flag(:unset_seen)
    end

    def set_star
      change_flag(:set_star)
    end

    def unset_star
      change_flag(:unset_star)
    end

    def change_flag(action)
      (params[:ids] || [params[:id]]).each do |id|
        item = @model.where(mailbox: @mailbox).imap_find(id) rescue nil
        item.try(action) if item
      end

      render_change
    end

    def move
      (params[:ids] || [params[:id]]).each do |id|
        item = @model.where(mailbox: @mailbox).imap_find(id) rescue nil
        item.move(params[:dst]) if item
      end
      render_change
    end

    def copy
      (params[:ids] || [params[:id]]).each do |id|
        item = @model.where(mailbox: @mailbox).imap_find(id) rescue nil
        item.copy(params[:dst]) if item
      end
      render_change
    end

    def render_change
      location = params[:redirect].presence || { action: :index }
      respond_to do |format|
        format.html { redirect_to location, notice: t('webmail.notice.changed') }
        format.json { head :no_content }
      end
    end

    def new
      @item = @model.new pre_params.merge(fix_params)

      if params[:reply]
        @item.new_reply params[:reply]
      elsif params[:reply_all]
        @item.new_reply_all params[:reply_all]
      elsif params[:forward]
        @item.new_forward params[:forward]
      else
        @item.new_create
      end

      raise "403" unless @item.allowed?(:edit, @cur_user)
    end

    def create
      @item = @model.new
      @item.mail_attributes = get_params

      msg = Webmail::Mailer.new_message(@item)

      if params[:commit] == I18n.t("views.button.save")
        @item.save_to_draft(msg.to_s)
        @item.destroy_files
      else
        @item.save_to_sent(msg.deliver_now.to_s)
        @item.destroy_files
      end

      render_create true
    end

    def destroy
      raise "403" unless @item.allowed?(:delete, @cur_user)
      render_destroy @item.destroy_or_trash
    end

    def destroy_all
      @items = @model.
        where(mailbox: @mailbox).
        in(uid: params[:ids]).
        entries.
        map(&:sync)

      entries = @items.entries
      @items = []

      entries.each do |item|
        if item.allowed?(:delete, @cur_user)
          next if item.destroy_or_trash
        else
          item.errors.add :base, :auth_error
        end
        @items << item
      end
      render_destroy_all(entries.size != @items.size)
    end
end
