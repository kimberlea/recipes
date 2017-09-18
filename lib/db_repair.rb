module DBRepair

  def self.update_meta(cls)
    cls.all.find_each do |m|
      m.update_meta
    end
  end

  def self.create_events
    if false
      Recipe.all.each do |r|
        ev = AppEvent.publish("recipe.created", r.creator, {recipe: r})
        ev.created_at = r.created_at; ev.save;
      end
      Comment.all.each do |c|
        ev = AppEvent.publish("recipe.commented", c.user, {recipe: c.recipe, comment: c})
        ev.created_at = c.created_at; ev.save;
      end
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

  def self.reprocess_uploads
    Recipe.find_each do |r|
      next if r.image.url.nil?
      begin
        r.image.cache_stored_file!
        r.image.retrieve_from_cache!(r.image.cache_name)
        r.image.recreate_versions!(:thumb)
      rescue => ex
        puts "ERROR: Recipe #{r.id}"
        puts ex.message
        puts ex.backtrace.join("\n\t")
      end
    end
    User.find_each do |r|
      next if r.picture.url.nil?
      begin
        r.picture.cache_stored_file!
        r.picture.retrieve_from_cache!(r.picture.cache_name)
        r.picture.recreate_versions!(:thumb)
      rescue => ex
        puts "ERROR: User #{r.id}"
        puts ex.message
        puts ex.backtrace.join("\n\t")
      end
    end
  end

  def self.migrate_to_dishes
    # app events
    AppEvent.where(action: "recipe.created").update_all(action: "dish.created")
    AppEvent.where(action: "recipe.favorited").update_all(action: "dish.favorited")
    AppEvent.where(action: "recipe.commented").update_all(action: "dish.commented")
  end

end
