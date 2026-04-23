require "test_helper"

class PetTest < ActiveSupport::TestCase
  def setup
    @owner = Owner.create!(first_name: "Juan", last_name: "Perez", email: "owner@test.com", phone: "123")
  end

  test "valid pet saves" do
    pet = Pet.new(name: "Firulais", species: "dog", date_of_birth: Date.today, weight: 10, owner: @owner)
    assert pet.save
  end

  test "invalid without name" do
    pet = Pet.new(species: "dog", date_of_birth: Date.today, weight: 10, owner: @owner)
    assert_not pet.save
    assert_includes pet.errors[:name], "can't be blank"
  end

  test "invalid without species" do
    pet = Pet.new(name: "Firulais", date_of_birth: Date.today, weight: 10, owner: @owner)
    assert_not pet.save
    assert_includes pet.errors[:species], "can't be blank"
  end

  test "invalid species" do
    pet = Pet.new(name: "Firulais", species: "dragon", date_of_birth: Date.today, weight: 10, owner: @owner)
    assert_not pet.save
    assert pet.errors[:species].any?
  end

  test "invalid without date_of_birth" do
    pet = Pet.new(name: "Firulais", species: "dog", weight: 10, owner: @owner)
    assert_not pet.save
    assert_includes pet.errors[:date_of_birth], "can't be blank"
  end

  test "date_of_birth cannot be in the future" do
    pet = Pet.new(name: "Firulais", species: "dog", date_of_birth: Date.tomorrow, weight: 10, owner: @owner)
    assert_not pet.save
    assert pet.errors[:date_of_birth].any?
  end

  test "invalid without weight" do
    pet = Pet.new(name: "Firulais", species: "dog", date_of_birth: Date.today, owner: @owner)
    assert_not pet.save
    assert_includes pet.errors[:weight], "can't be blank"
  end

  test "weight must be greater than 0" do
    pet = Pet.new(name: "Firulais", species: "dog", date_of_birth: Date.today, weight: 0, owner: @owner)
    assert_not pet.save
    assert pet.errors[:weight].any?
  end

  test "invalid without owner" do
    pet = Pet.new(name: "Firulais", species: "dog", date_of_birth: Date.today, weight: 10)
    assert_not pet.save
  end

  test "name is capitalized before save" do
    pet = Pet.create!(name: "firulais", species: "dog", date_of_birth: Date.today, weight: 10, owner: @owner)
    assert_equal "Firulais", pet.name
  end
end