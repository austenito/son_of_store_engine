class Store < ActiveRecord::Base
  attr_accessible :name, :slug, :owner_id, :description

  has_many :products
  has_many :privileges
  has_many :carts
  has_many :orders

  validates_presence_of :owner_id
  validates_uniqueness_of :name
  validates_uniqueness_of :slug


  def set_privilege(user, level)
    privileges.where(user_id: user.id).destroy_all
    privileges.create(user_id: user.id, name: level) if level
  end

  def privilege_for(user)
    privileges.find_by_user_id(user.id)
  end

end
