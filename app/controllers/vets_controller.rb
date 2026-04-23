class VetsController < ApplicationController
  def index
    @specializations = Vet.distinct.pluck(:specialization)
    @specialization = params[:specialization]
    @vets = @specialization.present? ? Vet.by_specialization(@specialization).includes(:appointments) : Vet.includes(:appointments)
  end

  def show
    @vet = Vet.find(params[:id])
  end
end