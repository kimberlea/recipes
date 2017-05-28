module SiteNotification

  def self.send_activity(opts={})
    User.find_each do |u|
      next if u.notification_frequency == 0
      if u.last_notification_at.nil?
        can_send = true
        since = 1.week.ago
      else
        np = u.notification_period
        since = u.last_notification_at
        nt = since + np
        can_send = Time.now > nt
      end
      next if !can_send
      self.send_activity_to_user(u, since)
    end
  end

  def self.send_activity_to_user(user, since, opts={})
    events = AppEvent.relevant_for_user(user).not_with_actor(user).created_after(since).limit(50).to_a
    return nil if events.empty?
    html = MailMaker.parse_template("app_events/activity", user: user, events: events)
    #puts html
    mail = QuickNotify::Mailer.app_email(to: user.email, subject: "Here's what you missed on Dishfave.", html_body: html)
    mail.deliver_now
    user.last_notification_at = Time.now
    user.save(validate: false)
    return mail
  end

end
