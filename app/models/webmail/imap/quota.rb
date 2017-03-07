module Webmail::Imap
  class Quota
    include Webmail::ImapAccessor

    def initialize
      @item = cache_find || Webmail::Quota.new(quota_root_scope)
    end

    def quota_root_scope
      imap.account_scope.merge(mailbox: 'ROOT')
    end

    def load
      reload? ? reload : @item
    end

    def reload?
      return true if @item.reloaded.blank?
      @item.reloaded + SS.config.webmail.cache_quota_expires.hours < Time.zone.now
    end

    def reload
      if info = imap_find
        @item.quota = info.quota
        @item.usage = info.usage
        @item.reloaded = Time.zone.now
        @item.save if SS.config.webmail.cache_quota
      end
      @item
    end

    def cache_find
      Webmail::Quota.where(quota_root_scope).first
    end

    def imap_find
      begin
        imap.conn.getquotaroot('INBOX')[1]
      rescue Net::IMAP::ResponseParseError
        nil
      end
    end
  end
end
