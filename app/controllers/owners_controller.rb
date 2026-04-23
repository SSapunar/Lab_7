class OwnersController < ApplicationController
  def index
    @owners = Owner.includes(:pets)
  end

  def show
    @owner = Owner.find(params[:id])
  end
end