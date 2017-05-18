module DBRepair

  def self.create_events
    Recipe.all.each do |r|
      ev = AppEvent.publish("recipe.created", r.creator, {recipe: r})
      ev.created_at = r.created_at; ev.save;
    end
    Comment.all.each do |c|
      ev = AppEvent.publish("recipe.commented", c.user, {recipe: c.recipe, comment: c})
      ev.created_at = c.created_at; ev.save;
    end
    UserReaction.all.each do |m|
      next if m.is_favorite != true
      ev = AppEvent.publish("recipe.favorited", m.user, {recipe: m.recipe})
      ev.created_at = m.created_at; ev.save;
    end
    Following.all.each do |m|
      ev = AppEvent.publish("user.followed", m.follower, {user: m.user})
      ev.created_at = m.created_at; ev.save;
    end
  end

end
