require 'pandora/validation/email_validator'
require 'pandora/validation/emails_validator'

class Email < ApplicationRecord

  include Util::Config

  translates :subject, :body, :body_html

  NOT_REQUIRED               = %w[body_html body_html_de]
  REQUIRED                   = %w[from to body]
  REQUIRED_UNLESS_NEWSLETTER = %w[subject_de body_de subject]

  validates_presence_of *REQUIRED
  validates_presence_of *REQUIRED_UNLESS_NEWSLETTER.dup.push(:unless => :newsletter?)

  SENDER_ADDRESS = "prometheus <#{ENV['PM_INFO_ADDRESS']}>".freeze
  SENDER_ADDRESS_NEWSLETTER = "prometheus <#{ENV['PM_NEWSLETTER_SENDER']}>".freeze

  validates_format_of :from, :with => %r{\A#{Regexp.escape(SENDER_ADDRESS)}|#{Regexp.escape(SENDER_ADDRESS_NEWSLETTER)}\z}
  validates :from, :'pandora/validation/email' => true
  validates :reply_to, :'pandora/validation/email' => true, allow_blank: true
  validates :to, :'pandora/validation/emails' => true
  validates :cc, :'pandora/validation/emails' => true, allow_blank: true

  RECIPIENT_FIELDS = %w[to cc bcc].freeze
  RECIPIENT_FIELDS.each { |field| serialize field, Array }

  def self.display_columns
    @display_columns ||= content_columns - columns_by_name(:subject, :body, :body_html)
  end

  def combined_subject(subject = nil)
    subject ||= subject_in_all_languages(' / ')
    newsletter? ? newsletter_subject(subject) : subject
  end

  def to_s
    newsletter? ? newsletter_subject(nil) : combined_subject[0, 40] << '...'
  end

  def sender(user = nil)
    delivered? ? sent_by : user && user.fullname_with_email
  end

  def from
    if newsletter?
      SENDER_ADDRESS_NEWSLETTER
    else
      self[:from] ||= SENDER_ADDRESS
    end
  end

  alias_method :from_before_type_cast, :from

  def to=(value)
    self[:to] = from_textarea(value)
  end

  def expanded_to
    recipients_for(self[:to])
  end

  def cc=(value)
    self[:cc] = from_textarea(value)
  end

  def expanded_cc
    recipients_for(self[:cc])
  end

  def bcc=(value)
    self[:bcc] = from_textarea(value)
  end

  def expanded_bcc
    recipients_for(self[:bcc])
  end

  def recipients
    @recipients ||= self[:to] + self[:cc] + self[:bcc]
  end

  def recipients_with_expansions
    @recipients_with_expansions ||= [
      ['to', self[:to].map{|r| [r, recipients_for(r)]}],
      ['cc', self[:cc].map{|r| [r, recipients_for(r)]}],
      ['bcc', self[:bcc].map{|r| [r, recipients_for(r)]}]
    ]
  end

  def recipients_by_address
    @recipients_by_address ||= Hash.new { |h, k|
      h[k] = Account.email_verified.find_by(email: k)
    }
  end

  def deliver_now(by)
    recipients = {
      :to  => expanded_to,
      :cc  => expanded_cc,
      :bcc => expanded_bcc
    }

    recipients.each do |field, accounts|
      accounts.each do |account|
        MassMailer.with(
          email: self,
          to: {field => account.email},
          user: account,
          by: by.fullname_with_email
        ).email.deliver_later
      end
    end
  end

  # Enqueue a job to deliver a newsletter. The method returns immediately after
  # setting the 'delivered' flag. The individual delivery jobs are then enqueued
  # by the background job.
  def deliver_later(by)
    raise DoubleSendError if delivered?

    DeliverNewsletterJob.perform_later(id, by.id)

    delivered!(by.fullname_with_email)
  end

  def delivered!(by = nil)
    update_columns(
      sent_at: Time.now.utc,
      sent_by: by
    )
  end

  alias_method :sent!, :delivered!

  def delivered?
    !pending?
  end

  alias_method :sent?, :delivered?

  def self.delivered
    where('sent_at IS NOT NULL')
  end

  def self.newsletters
    where('newsletter IS NOT NULL')
  end

  def self.pending
    where('sent_at IS NULL')
  end

  def self.search(column, value)
    return all if column.blank? or value.blank?

    case column
    when 'combined_subject'
      where("CONCAT(subject, ' ', subject_de) LIKE ?", "%#{value}%")
    when 'combined_body'
      where("CONCAT(body, ' ', body_de) LIKE ?", "%#{value}%")
    when 'recipients'
      ids = Email.all.select do |email|
        email.recipients.any? do |recipient|
          v = Regexp.escape(value)
          recipient.match?(/#{v}/)
        end
      end

      where(id: ids)
    else
      raise(
        Pandora::Exception,
        "unknown search criteria for Email/Newsletter: #{column}"
      )
    end
  end

  def self.sorted(column, direction)
    return all if column.blank?

    case column
    when 'combined_subject'
      if I18n.locale == :de
        order(subject_de: direction)
      else
        order(subject: direction)
      end
    when 'updated_at', 'sent_at', 'subject'
      order(column => direction)
    else
      raise(
        Pandora::Exception,
        "unknown sort criteria for Email/Newsletter: #{column}"
      )
    end
  end

  def year
    (sent_at || updated_at || Time.now.utc).year
  end

  def pending?
    sent_at.nil?
  end

  # REWRITE: changed to prevent circular argument definition. Does it do the
  # expected?
  def newsletter_subject(subject = self.subject)
    "#{'%d / %02d' % [year, newsletter]}#{': ' unless subject.blank?}#{subject}"
  end

  class << self
    def newsletter
      new(
        :to         => ['newsletter'],
        :tag        => 'Newsletter',
        :newsletter => next_newsletter,
        :individual => true
      )
    end


    private

      def next_newsletter
        last = newsletters.order(id: :desc).first
        last && last.year == Time.now.utc.year ? last.newsletter + 1 : 1
      end

  end

  
  private
  
    def recipients_for(recipients)
      case recipients
      when Array
        recipients.map{|r| recipients_for(r)}.flatten.compact
      when 'newsletter'
        Account.
          email_verified.
          where(newsletter: true)
      end
    end

    class DoubleSendError < StandardError; end

end
