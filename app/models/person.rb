class Person < ActiveRecord::Base

  hobo_model # Don't put anything above this
  
  Title = HoboFields::EnumString.for("Mr.", "Mrs.", "Miss", "Ms.", "Dr.", "Rev.", "Sister", "Fr.")
  Gender = HoboFields::EnumString.for(:male, :female)
  
  fields do
    first_name      :string, :required
    last_name       :string, :required
    title           Person::Title, :required
    gender          Person::Gender, :required
    cell_number     :string
    landline_number :string
    fax_number      :string
    email_address   :email_address
    timestamps
  end
  
  has_many :appointments, :dependent => :destroy
  
  def last_institution
    # TODO Implement; find the institution of the most recent appointment
  end
  
  # --- Permissions --- #
  
  def create_permitted?
    acting_user.signed_up?
  end

  def update_permitted?
    acting_user.signed_up?
  end
  
  def destroy_permitted?
    acting_user.administrator?
  end
  
  def view_permitted?(field)
    acting_user.signed_up?
  end
  
  def name
    "#{first_name} #{last_name}"
  end

end