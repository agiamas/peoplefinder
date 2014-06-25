class GroupMembershipsController < ApplicationController
  before_action :set_group
  before_action :set_membership, only: [:show, :edit, :update, :destroy]

  # GET /memberships
  # GET /memberships.json
  def index
    @memberships = collection.all
  end

  # GET /memberships/1
  # GET /memberships/1.json
  def show
  end

  # GET /memberships/new
  def new
    @membership = collection.new
  end

  # GET /memberships/1/edit
  def edit
  end

  # POST /memberships
  # POST /memberships.json
  def create
    @membership = collection.new(membership_params)

    if @membership.save
      redirect_to group_memberships_path(@group), notice: 'Membership was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /memberships/1
  # PATCH/PUT /memberships/1.json
  def update
    if @membership.update(membership_params)
      redirect_to group_memberships_path(@group), notice: 'Membership was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /memberships/1
  # DELETE /memberships/1.json
  def destroy
    @membership.destroy
    redirect_to group_memberships_path(@group), notice: 'Membership was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_membership
      @membership = collection.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def membership_params
      params.require(:membership).permit(:role, :person_id, :leader)
    end

    def collection
      @group.memberships.includes(:person)
    end

    def set_group
      @group ||= Group.friendly.find(params[:group_id])
    end
end