module SS::Model::Task
  extend ActiveSupport::Concern
  extend SS::Translation
  include SS::Document
  include SS::Reference::Site
  include SS::Reference::User

  STATE_STOP = "stop".freeze
  STATE_READY = "ready".freeze
  STATE_RUNNING = "running".freeze
  STATE_COMPLETED = "completed".freeze
  STATE_FAILED = "failed".freeze
  STATE_INTERRUPTED = "interrupted".freeze

  included do
    store_in collection: "ss_tasks"
    store_in_repl_master

    self.site_required = false

    attr_accessor :log_buffer

    seqid :id
    field :name, type: String
    # field :command, type: String
    field :state, type: String, default: STATE_STOP
    field :interrupt, type: String
    field :started, type: DateTime
    field :closed, type: DateTime
    field :total_count, type: Integer, default: 0
    field :current_count, type: Integer, default: 0

    validates :name, presence: true
    validates :state, presence: true
    validates :started, datetime: true
    validates :closed, datetime: true

    after_initialize :init_variables
  end

  class Interrupt < StandardError
  end

  module ClassMethods
    def ready(cond, &block)
      task = self.find_or_create_by(cond)
      return false unless task.start

      state = STATE_STOP
      begin
        require 'benchmark'
        time = Benchmark.realtime { yield task }
        task.log sprintf("# %d sec\n\n", time)
        state = STATE_COMPLETED
      rescue Interrupt => e
        task.log "-- #{e}"
        # task.log e.backtrace.join("\n")
        state = STATE_INTERRUPTED
      rescue StandardError => e
        task.log "-- Error"
        task.log e.to_s
        task.log e.backtrace.join("\n")
        state = STATE_FAILED
      ensure
        task.close(state)
      end
    end

    def search(params)
      all.search_keyword(params).search_site(params).search_state(params)
    end

    def search_keyword(params)
      return all if params.blank || params[:keyword].blank?

      all.keyword_in(params[:keyword], :name)
    end

    def search_site(params)
      return all if params.blank || params[:site_id].blank?

      all.where(site_id: params[:site_id])
    end

    def search_state(params)
      return all if params.blank || params[:state].blank?

      all.where(state: params[:state])
    end
  end

  def count(other = 1)
    self.current_count += other
    if (self.current_count % log_buffer) == 0
      save
      interrupt = self.class.find_by(id: id, select: interrupt).interrupt
      raise Interrupt, "interrupted: stop" if interrupt.to_s == "stop"
      # GC.start
    end
    self
  end

  def init_variables
    self.log_buffer = 50
  end

  def running?(limit = 1.day)
    state == STATE_RUNNING && (started.presence || updated) + limit > Time.zone.now
  end

  def start
    if running?
      Rails.logger.info "already running."
      return false
    end

    change_state(STATE_RUNNING, { started: Time.zone.now })
  end

  def ready
    if running?
      Rails.logger.info "already running."
      return false
    end
    if state == STATE_READY
      Rails.logger.info "already ready."
      return false
    end
    unless ApplicationJob.check_size_limit_per_user?(user_id)
      Rails.logger.info I18n.t('job.notice.size_limit_exceeded')
      return false
    end

    change_state(STATE_READY)
  end

  def close(state = STATE_STOP)
    self.closed = Time.zone.now
    self.state  = state
    result = save

    if result && @log_file
      @log_file.close
      @log_file = nil
    end

    result
  end

  def clear_log(msg = nil)
    if @log_file
      @log_file.close
      @log_file = nil
    end

    self.unset(:logs) if self[:logs].present?

    ::FileUtils.rm_f(log_file_path) if log_file_path && ::File.exists?(log_file_path)
  end

  def log_file_path
    return if new_record?
    @log_file_path ||= "#{SS::File.root}/ss_tasks/" + id.to_s.split(//).join("/") + "/_/#{id}.log"
  end

  def logs
    if log_file_path && ::File.exists?(log_file_path)
      return ::File.readlines(log_file_path, chomp: true) rescue []
    end

    []
  end

  def head_logs(num_logs = 1_000)
    if log_file_path && ::File.exists?(log_file_path)
      texts = []
      ::File.open(log_file_path) do |f|
        num_logs.times do
          line = f.gets || break
          texts << line.chomp
        end
      end
      texts
    else
      []
    end
  end

  def log(msg)
    @log_file ||= begin
      dirname = ::File.dirname(log_file_path)
      ::FileUtils.mkdir_p(dirname) unless ::Dir.exists?(dirname)

      file = ::File.open(log_file_path, 'a')
      file.sync = true
      file
    end

    puts msg
    @log_file.puts msg
    Rails.logger.info msg
  end

  def process(controller, action, params = {})
    agent = SS::Agent.new controller
    agent.controller.instance_variable_set :@task, self
    params.each do |k, v|
      agent.controller.instance_variable_set :"@#{k}", v
    end
    agent.invoke action
  end

  private

  def change_state(state, attrs = {})
    self.started       = attrs[:started]
    self.closed        = nil
    self.state         = state
    self.interrupt     = nil
    self.total_count   = 0
    self.current_count = 0
    result = save

    clear_log if result

    result
  end
end
