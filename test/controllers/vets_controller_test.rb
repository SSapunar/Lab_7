require "test_helper"

class VetsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @vet = vets(:one)
  end

  test "should get index" do
    get vets_url
    assert_response :success
  end

  test "should show vet" do
    get vet_url(@vet)
    assert_response :success
  end

  test "should create vet" do
    assert_difference("Vet.count") do
      post vets_url, params: {
        vet: {
            first_name: "John",
            last_name: "Doe",
            email: "john_new@test.com",
            phone: "123456",
            specialization: "surgery"   # 👈 AGREGA ESTO
        }
      }
    end
    assert_redirected_to vet_url(Vet.last)
  end

  test "should not create invalid vet" do
    post vets_url, params: { vet: { first_name: "" } }
    assert_response :unprocessable_entity
  end

  test "should update vet" do
    patch vet_url(@vet), params: {
      vet: { first_name: "Updated" }
    }
    assert_redirected_to vet_url(@vet)
  end

  test "should destroy vet" do
    assert_difference("Vet.count", -1) do
      delete vet_url(@vet)
    end
    assert_redirected_to vets_url
  end
end