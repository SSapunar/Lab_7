class PetsController < ApplicationController
  before_action :set_pet, only: [:show, :edit, :update, :destroy]

  def index
    @species_list = Pet.distinct.pluck(:species)
    @species = params[:species]
    @pets = @species.present? ? Pet.by_species(@species).includes(:owner) : Pet.includes(:owner)
  end

  def show
    @pet = Pet.includes(appointments: [:vet, :treatments]).find(params[:id])
  end

  def new
    @pet = Pet.new
  end

  def create
    @pet = Pet.new(pet_params)
    if @pet.save
      redirect_to @pet, notice: "Pet created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @pet.update(pet_params)
      redirect_to @pet, notice: "Pet updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @pet.destroy
    redirect_to pets_path, notice: "Pet deleted successfully."
  end

  private

  def set_pet
    @pet = Pet.find(params[:id])
  end

  def pet_params
    params.require(:pet).permit(:name, :species, :breed, :date_of_birth, :weight, :owner_id)
  end
end