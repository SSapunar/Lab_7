class PetsController < ApplicationController
  def index
    @species_list = Pet.distinct.pluck(:species)
    @species = params[:species]
    @pets = @species.present? ? Pet.by_species(@species).includes(:owner) : Pet.includes(:owner)
  end

  def show
    @pet = Pet.includes(appointments: [:vet, :treatments]).find(params[:id])
  end
end