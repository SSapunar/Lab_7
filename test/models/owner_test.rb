require "test_helper"

class OwnerTest < ActiveSupport::TestCase
  test "valid owner saves" do
    owner = Owner.new(first_name: "Juan", last_name: "Perez", email: "juan@test.com", phone: "123")
    assert owner.save
  end

  test "invalid without first_name" do
    owner = Owner.new(last_name: "Perez", email: "juan@test.com", phone: "123")
    assert_not owner.save
    assert_includes owner.errors[:first_name], "can't be blank"
  end

  test "invalid without last_name" do
    owner = Owner.new(first_name: "Juan", email: "juan@test.com", phone: "123")
    assert_not owner.save
    assert_includes owner.errors[:last_name], "can't be blank"
  end

  test "invalid without email" do
    owner = Owner.new(first_name: "Juan", last_name: "Perez", phone: "123")
    assert_not owner.save
    assert_includes owner.errors[:email], "can't be blank"
  end

  test "invalid with bad email format" do
    owner = Owner.new(first_name: "Juan", last_name: "Perez", email: "notanemail", phone: "123")
    assert_not owner.save
    assert owner.errors[:email].any?
  end

  test "email must be unique" do
    owner1 = Owner.new(first_name: "A", last_name: "B", email: "test@test.com", phone: "123")
    owner1.save!

    owner2 = Owner.new(first_name: "C", last_name: "D", email: "test@test.com", phone: "456")
    assert_not owner2.save
    assert_includes owner2.errors[:email], "has already been taken"
  end

  test "invalid without phone" do
    owner = Owner.new(first_name: "Juan", last_name: "Perez", email: "juan@test.com")
    assert_not owner.save
    assert_includes owner.errors[:phone], "can't be blank"
  end

  test "email is normalized before save" do
    owner = Owner.new(first_name: "Juan", last_name: "Perez", email: "  JUAN@TEST.COM  ", phone: "123")
    assert owner.save
    assert_equal "juan@test.com", owner.email
  end
end