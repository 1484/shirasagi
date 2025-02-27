class Fs::FilesController < ApplicationController
  include SS::AuthFilter
  include Member::AuthFilter
  include Cms::PublicFilter::Site

  before_action :set_user
  before_action :set_item
  before_action :deny
  rescue_from StandardError, with: :rescue_action

  private

  def set_user
    @cur_user, _login_path, _logout_path = get_user_by_access_token
    @cur_user ||= get_user_by_session
  end

  def set_item
    id = params[:id_path].present? ? params[:id_path].gsub(/\//, "") : params[:id]
    name_or_filename = params[:filename]
    name_or_filename << ".#{params[:format]}" if params[:format].present?

    item = SS::File.find(id)
    raise "404" if item.name != name_or_filename && item.filename != name_or_filename

    @item = item.becomes_with_model
    raise "404" if @item.try(:thumb?)
  end

  def deny
    raise "404" unless @item.previewable?(user: @cur_user, member: get_member_by_session)
    set_last_logged_in
  end

  def set_last_modified
    response.headers["Last-Modified"] = CGI::rfc1123_date(@item.updated.in_time_zone)
  end

  def rescue_action(error = nil)
    if error.to_s.numeric?
      status = error.to_s.to_i
      file = error_html_file(status)
      return ss_send_file(file, status: status, type: Fs.content_type(file), disposition: :inline)
    end
    if error.is_a?(Mongoid::Errors::DocumentNotFound)
      status = 404
      file = error_html_file(status)
      return ss_send_file(file, status: status, type: Fs.content_type(file), disposition: :inline)
    end
    raise error
  end

  def error_html_file(status)
    if @cur_site && @cur_user.nil?
      file = "#{@cur_site.path}/#{status}.html"
      return file if Fs.exists?(file)
    end

    file = "#{Rails.public_path}/.error_pages/#{status}.html"
    Fs.exists?(file) ? file : "#{Rails.public_path}/.error_pages/500.html"
  end

  def send_item(disposition = :inline)
    set_last_modified

    if Fs.mode == :file && Fs.file?(@item.path)
      send_file @item.path, type: @item.content_type, filename: @item.download_filename,
                disposition: disposition, x_sendfile: true
    else
      send_enum @item.to_io, type: @item.content_type, filename: @item.download_filename,
                disposition: disposition
    end
  end

  def send_thumb(file, opts = {})
    width  = opts.delete(:width).to_i
    height = opts.delete(:height).to_i

    width  = (width  > 0) ? width  : SS::ImageConverter::DEFAULT_THUMB_WIDTH
    height = (height > 0) ? height : SS::ImageConverter::DEFAULT_THUMB_HEIGHT

    converter = SS::ImageConverter.open(file.path)
    converter.resize_to_fit!(width, height)

    send_enum converter.to_enum, opts
    converter = nil
  ensure
    if converter
      converter.close rescue nil
    end
  end

  public

  def index
    send_item
  end

  def thumb
    size   = params[:size]
    width  = params[:width]
    height = params[:height]

    if width.present? && height.present?
      set_last_modified
      send_thumb @item, type: @item.content_type, filename: @item.filename,
        disposition: :inline, width: width, height: height
    elsif thumb  = @item.try(:thumb, size)
      @item = thumb
      index
    else
      set_last_modified
      send_thumb @item, type: @item.content_type, filename: @item.filename,
        disposition: :inline
    end
  rescue => e
    raise "500"
  end

  def download
    send_item(DEFAULT_SEND_FILE_DISPOSITION)
  end

  alias view index
end
