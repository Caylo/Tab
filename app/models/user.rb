# == Schema Information
#
# Table name: users
#
#  id                  :integer          not null, primary key
#  name                :string(255)
#  last_name           :string(255)
#  balance             :integer          default(0)
#  nickname            :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#  encrypted_password  :string(255)      default(""), not null
#  remember_created_at :datetime
#  sign_in_count       :integer          default(0), not null
#  current_sign_in_at  :datetime
#  last_sign_in_at     :datetime
#  current_sign_in_ip  :string(255)
#  last_sign_in_ip     :string(255)
#  admin               :boolean
#  dagschotel_id       :integer
#  avatar_file_name    :string(255)
#  avatar_content_type :string(255)
#  avatar_file_size    :integer
#  avatar_updated_at   :datetime
#  orders_count        :integer          default(0)
#  koelkast            :boolean          default(FALSE)
#

class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :rememberable, :trackable
  has_paper_trail only: [:balance, :admin, :orders_count, :koelkast]
  has_attached_file :avatar, styles: { medium: "100x100>" }, default_style: :medium,
      default_url: "http://babeholder.pixoil.com/img/70/70"

  has_many :orders, -> { includes :products }
  has_many :products, through: :orders
  belongs_to :dagschotel, class_name: 'Product'

  validates :nickname, presence: true, uniqueness: true
  validates :name, presence: true
  validates :last_name, presence: true
  validates :password, length: { in: 8..128 }, confirmation: true, on: :create
  validates_attachment :avatar, presence: true, content_type: { content_type: ["image/jpeg", "image/gif", "image/png"] }

  scope :members, -> { where koelkast: false }

  def full_name
    "#{name} #{last_name}"
  end

  def pay(amount)
    write_attribute(:balance, read_attribute(:balance) - amount)
    self.save
  end

  def balance
    (read_attribute(:balance) || 0) / 100.0
  end

  def balance=(value)
    if value.is_a? String then value.sub!(',', '.') end
    write_attribute(:balance, (value.to_f * 100).to_int)
  end
end
