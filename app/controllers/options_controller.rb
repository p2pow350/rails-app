class OptionsController < ApplicationController
  before_action :set_option, only: [:show, :edit, :update, :destroy]
  semantic_breadcrumb :index, :options_path


  def index
  	s_filter = params[:q]
  	s_criteria = params[:search_criteria]
  	
  	@per_page = params[:per_page] || WillPaginate.per_page
  	  
    if s_filter
      @options = Option.where.has { sql(s_criteria) =~ "%#{s_filter}%" }.paginate(:per_page => @per_page, :page => params[:page])
    else
      @options = Option.all.paginate(:per_page => @per_page, :page => params[:page])
    end    
    
    respond_to do |format|
	  format.html
	  format.xls { send_data(@options.to_a.to_xls(:except => [:created_at, :updated_at, :id])) }
	  format.csv { send_data(@options.to_a.to_csv(:except => [:created_at, :updated_at, :id])) }
    end    
  end

  
  def new
    @option = Option.new
  end

  
  def edit
  	 semantic_breadcrumb @option.o_key, option_path(@option)  	  
  end

  
  def create
    @option = Option.new(option_params)

    if @option.save
      redirect_to action: :index, notice: "'#{@option.o_key}' was successfully created."
    else
      render :new, alert: @option.errors.full_messages  
    end
  end

  
  def update
    if @option.update(option_params)
      redirect_to options_url, notice: "'#{@option.o_key}' was successfully updated."
    else
      render :edit, alert: @option.errors.full_messages  
    end
  end

  def destroy
    @option.destroy
    respond_to do |format|
      format.html { redirect_to options_url, notice: "'#{@option.o_key}' was successfully deleted." }
      format.json { head :no_content }
    end
  end
  
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_option
      @option = Option.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def option_params
      params.require(:option).permit(:o_key, :value, :area, :search_criteria, :q)
    end
end
