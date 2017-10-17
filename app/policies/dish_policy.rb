class DishPolicy < QuickScript::PunditPolicy

  def update?
    # can save new record
    return true if record.new_record?
    # only update if mine or admin
    return false if user.nil?
    record.creator_id == user.id || user.is_superadmin
  end

  def view_full?
    update?
  end

  def delete?
    update?
  end

  def manage_features?
    update?
  end

end
