require "test_helper"

class AppointmentTest < ActiveSupport::TestCase
  def setup
    @owner = Owner.create!(first_name: "Juan", last_name: "Perez", email: "owner@test.com", phone: "123")
    @pet = Pet.create!(name: "Firulais", species: "dog", date_of_birth: Date.today, weight: 10, owner: @owner)
    @vet = Vet.create!(first_name: "Ana", last_name: "Lopez", email: "vet@test.com", phone: "123", specialization: "General")
  end

  test "valid appointment saves" do
    appt = Appointment.new(date: Time.now, reason: "Checkup", status: :scheduled, pet: @pet, vet: @vet)
    assert appt.save
  end

  test "invalid without date" do
    appt = Appointment.new(reason: "Checkup", status: :scheduled, pet: @pet, vet: @vet)
    assert_not appt.save
    assert_includes appt.errors[:date], "can't be blank"
  end

  test "invalid without reason" do
    appt = Appointment.new(date: Time.now, status: :scheduled, pet: @pet, vet: @vet)
    assert_not appt.save
    assert_includes appt.errors[:reason], "can't be blank"
  end

  test "invalid without status" do
    appt = Appointment.new(date: Time.now, reason: "Checkup", pet: @pet, vet: @vet)
    assert_not appt.save
    assert_includes appt.errors[:status], "can't be blank"
  end

  test "invalid without pet" do
    appt = Appointment.new(date: Time.now, reason: "Checkup", status: :scheduled, vet: @vet)
    assert_not appt.save
  end

  test "invalid without vet" do
    appt = Appointment.new(date: Time.now, reason: "Checkup", status: :scheduled, pet: @pet)
    assert_not appt.save
  end
end