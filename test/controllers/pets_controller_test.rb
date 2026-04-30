require "test_helper"

class PetsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @pet = pets(:one)
    @owner = owners(:one)
  end

  test "should get index" do
    get pets_url
    assert_response :success
  end

  test "should show pet" do
    get pet_url(@pet)
    assert_response :success
  end

  test "should create pet" do
    assert_difference("Pet.count") do
        post pets_url, params: {
        pet: {
            name: "Firulais",
            species: @pet.species,
            breed: @pet.breed,
            date_of_birth: @pet.date_of_birth,
            weight: @pet.weight,
            owner_id: owners(:one).id
        }
        }
    end
    assert_redirected_to pet_url(Pet.last)
  end

  test "should not create invalid pet" do
    post pets_url, params: { pet: { name: "" } }
    assert_response :unprocessable_entity
  end

  test "should update pet" do
    patch pet_url(@pet), params: {
      pet: { name: "Updated" }
    }
    assert_redirected_to pet_url(@pet)
  end

  test "should destroy pet" do
    assert_difference("Pet.count", -1) do
      delete pet_url(@pet)
    end
    assert_redirected_to pets_url
  end
end