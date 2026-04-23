require "test_helper"

class TreatmentTest < ActiveSupport::TestCase
  def setup
    owner = Owner.create!(first_name: "Juan", last_name: "Perez", email: "owner@test.com", phone: "123")
    pet = Pet.create!(name: "Firulais", species: "dog", date_of_birth: Date.today, weight: 10, owner: owner)
    vet = Vet.create!(first_name: "Ana", last_name: "Lopez", email: "vet@test.com", phone: "123", specialization: "General")
    @appointment = Appointment.create!(date: Time.now, reason: "Checkup", status: :scheduled, pet: pet, vet: vet)
  end

  test "valid treatment saves" do
    treatment = Treatment.new(name: "Vaccine", administered_at: Time.now, appointment: @appointment)
    assert treatment.save
  end

  test "invalid without name" do
    treatment = Treatment.new(administered_at: Time.now, appointment: @appointment)
    assert_not treatment.save
    assert_includes treatment.errors[:name], "can't be blank"
  end

  test "invalid without administered_at" do
    treatment = Treatment.new(name: "Vaccine", appointment: @appointment)
    assert_not treatment.save
    assert_includes treatment.errors[:administered_at], "can't be blank"
  end

  test "invalid without appointment" do
    treatment = Treatment.new(name: "Vaccine", administered_at: Time.now)
    assert_not treatment.save
  end
end