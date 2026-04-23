require "test_helper"

class VetTest < ActiveSupport::TestCase
  test "valid vet saves" do
    vet = Vet.new(first_name: "Ana", last_name: "Lopez", email: "vet@test.com", phone: "123", specialization: "General")
    assert vet.save
  end

  test "invalid without first_name" do
    vet = Vet.new(last_name: "Lopez", email: "vet@test.com", phone: "123", specialization: "General")
    assert_not vet.save
    assert_includes vet.errors[:first_name], "can't be blank"
  end

  test "invalid without last_name" do
    vet = Vet.new(first_name: "Ana", email: "vet@test.com", phone: "123", specialization: "General")
    assert_not vet.save
    assert_includes vet.errors[:last_name], "can't be blank"
  end

  test "invalid without email" do
    vet = Vet.new(first_name: "Ana", last_name: "Lopez", phone: "123", specialization: "General")
    assert_not vet.save
    assert_includes vet.errors[:email], "can't be blank"
  end

  test "invalid with bad email format" do
    vet = Vet.new(first_name: "Ana", last_name: "Lopez", email: "notanemail", phone: "123", specialization: "General")
    assert_not vet.save
    assert vet.errors[:email].any?
  end

  test "email must be unique" do
    vet1 = Vet.new(first_name: "A", last_name: "B", email: "vet@test.com", phone: "123", specialization: "General")
    vet1.save!

    vet2 = Vet.new(first_name: "C", last_name: "D", email: "vet@test.com", phone: "456", specialization: "Surgery")
    assert_not vet2.save
    assert_includes vet2.errors[:email], "has already been taken"
  end

  test "invalid without specialization" do
    vet = Vet.new(first_name: "Ana", last_name: "Lopez", email: "vet@test.com", phone: "123")
    assert_not vet.save
    assert_includes vet.errors[:specialization], "can't be blank"
  end

  test "email is normalized before save" do
    vet = Vet.new(first_name: "Ana", last_name: "Lopez", email: "  ANA@VET.COM  ", phone: "123", specialization: "General")
    assert vet.save
    assert_equal "ana@vet.com", vet.email
  end
end