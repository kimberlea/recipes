module SiteNotification

  def self.send_activity_to_user(user, since, opts={})
    events = AppEvent.relevant_for_user(user).created_after(since).limit(50)
    html = MailMaker.parse_template("app_events/activity", user: user, events: events)
    puts html
    mail = QuickNotify::Mailer.app_email(to: user.email, subject: "Here's what you missed on Dishfave.", html_body: html)
    return mail
  end

end
