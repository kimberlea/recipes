class UserPolicy < QuickScript::PunditPolicy

  def update?
    return true if record.new_record?
    return false if user.nil?
    record.id == user.id || user.is_superadmin
  end

end
