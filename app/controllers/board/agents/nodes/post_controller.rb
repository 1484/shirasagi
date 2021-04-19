class Board::Agents::Nodes::PostController < ApplicationController
  include Cms::NodeFilter::View
  include Cms::PublicFilter::Crud
  include SS::CaptchaFilter

  model Board::Post

  before_action :deny
  before_action :set_topic, only: [:new_reply, :reply]
  before_action :set_item, only: [:delete, :destroy]
  before_action :generate_captcha, only: [:new_reply, :delete, :new], if: ->{ @cur_node.captcha_enabled? }
  after_action :generate, only: [:create, :reply, :destroy]

  private

  def deny
    if @cur_node.deny_ips.present?
      remote_ip = remote_addr
      @cur_node.deny_ips.each do |deny_ip|
        raise "403" if remote_ip.match?(/^#{deny_ip}/)
      end
    end
  end

  def fix_params
    { cur_site: @cur_site, cur_node: @cur_node, parent: @topic }
  end

  def set_topic
    @topic = @model.topic.site(@cur_site).
      where(id: params[:parent_id], node_id: @cur_node.id).first
    raise "404" unless @topic
  end

  def set_item
    @item = @model.site(@cur_site).
      where(id: params[:parent_id], node_id: @cur_node.id).first
    raise "404" unless @item
  end

  def generate
    return unless @item.errors.empty?

    agent = SS::Agent.new Board::Agents::Tasks::Node::PostsController
    agent.controller.instance_variable_set :@cur_node, @cur_node
    agent.controller.instance_variable_set :@node, @cur_node
    agent.invoke(:generate)
  end

  public

  def index
    model = (@cur_node.mode == "tree") ? @model.topic : @model
    order = (@cur_node.mode == "tree") ? :descendants_updated : :updated
    @items = model.site(@cur_site).node(@cur_node).
      order(order => -1).
      page(params[:page]).
      per(@cur_node.limit)

    render_with_pagination(@items)
  end

  def create
    @item = @model.new get_params
    if @cur_node.captcha_enabled?
      return if render_pre_page?(@item, :new)
    end
    render_create @item.save, location: "#{@cur_node.url}sent", render: :new
  end

  def new_reply
    @item = @model.new pre_params
    @item.name = "Re:#{@topic.name}"
  end

  def reply
    @item = @model.new get_params
    if @cur_node.captcha_enabled?
      return if render_pre_page?(@item, :new_reply)
    end

    render_create @item.save, location: "#{@cur_node.url}sent", render: :new_reply
  end

  def delete
    raise "404" unless @cur_node.deletable_post?
    raise "404" unless @item.delete_key.present?
    @item.delete_key = ""
  end

  def destroy
    raise "404" unless @cur_node.deletable_post?
    raise "404" unless @item.delete_key.present?
    @item.delete_key = ""
    @item.attributes = get_params
    @item.captcha_answer = params[:answer].try(:[], :captcha_answer)
    @item.captcha_text = SS::CaptchaBase::Captcha.find_by(captcha_key: session[:captcha_key]).captcha_text

    if @cur_node.captcha_enabled?
      if @item.delete_key_was == @item.delete_key && @item.valid_with_captcha?
        render_destroy @item.destroy, location: "#{@cur_node.url}sent", render: :delete
        return
      else
        @item.errors.add :base, t("board.errors.not_same_delete_key")
      end
    end

    @item.delete_key = ""
    render :delete
  end

  def search
    @items = []
    return if params[:keyword].blank?

    @words = params[:keyword].split(/[\s　]+/).uniq.compact
    @query = @words.map do |w|
      [ { name: /#{::Regexp.escape(w)}/ }, { text: /#{::Regexp.escape(w)}/ } ]
    end.flatten

    @items = @model.site(@cur_site).node(@cur_node).or(@query).
      page(params[:page]).
      per(@cur_node.limit)
  end
end
