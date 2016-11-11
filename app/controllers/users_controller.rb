class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  semantic_breadcrumb :index, :users_admin_index_path


  def index
  	s_filter = params[:q]
  	s_criteria = params[:search_criteria]
  	
  	params[:per_page] = User.count if params[:per_page] == 'All'
  	@per_page = params[:per_page] || WillPaginate.per_page
  	  
    if s_filter
      @users = User.where.has { sql(s_criteria) =~ "%#{s_filter}%" }.paginate(:per_page => @per_page, :page => params[:page])
    else
      @users = User.all.paginate(:per_page => @per_page, :page => params[:page])
    end    
    
    respond_to do |format|
	  format.html
	  format.xls { send_data(@users.to_a.to_xls(:except => [:created_at, :updated_at, :id])) }
	  format.csv { send_data(@users.to_a.to_csv(:except => [:created_at, :updated_at, :id])) }
    end    
  end

  
  def new
    @user = User.new
  end
  
  def edit
  	 semantic_breadcrumb @user.email, users_admin_path(@user)  	  
  end

  
  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to action: :index, notice: "'#{@user.name}' was successfully created."
    else
      render :new, alert: @user.errors.full_messages  
    end
  end

  
  def update
    if @user.update(user_params)
      redirect_to users_admin_index_path, notice: "'#{@user.email}' was successfully updated."
    else
      render :edit, alert: @user.errors.full_messages  
    end
  end

  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_admin_index_path, notice: "'#{@user.email}' was successfully deleted." }
      format.json { head :no_content }
    end
  end

    
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:email, :name, :password, :default_locale, :search_criteria, :q)
    end
end
