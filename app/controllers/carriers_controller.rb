class CarriersController < ApplicationController
  before_action :set_carrier, only: [:show, :edit, :update, :destroy]
  semantic_breadcrumb :index, :carriers_path


  def index
  	s_filter = params[:q]
  	s_criteria = params[:search_criteria]
  	
  	@per_page = params[:per_page] || WillPaginate.per_page
  	  
    if s_filter
      @carriers = Carrier.where.has { sql(s_criteria) =~ "%#{s_filter}%" }.paginate(:per_page => @per_page, :page => params[:page])
    else
      @carriers = Carrier.all.paginate(:per_page => @per_page, :page => params[:page])
    end    
    
    respond_to do |format|
	  format.html
	  format.xls { send_data(@carriers.to_xls(:except => [:created_at, :updated_at, :id])) }
	  format.csv { send_data(@carriers.to_csv(:except => [:created_at, :updated_at, :id])) }
    end    
  end

  
  def new
    @carrier = Carrier.new
  end

  
  def edit
  	 semantic_breadcrumb @carrier.name, carrier_path(@carrier)  	  
  end

  
  def create
    @carrier = Carrier.new(carrier_params)

    if @carrier.save
      redirect_to action: :index, notice: "'#{@carrier.name}' was successfully created."
    else
      render :new, alert: @carrier.errors.full_messages  
    end
  end

  
  def update
    if @carrier.update(carrier_params)
      redirect_to carriers_url, notice: "'#{@carrier.name}' was successfully updated."
    else
      render :edit, alert: @carrier.errors.full_messages  
    end
  end

  def destroy
    @carrier.destroy
    respond_to do |format|
      format.html { redirect_to carriers_url, notice: "'#{@carrier.name}' was successfully deleted." }
      format.json { head :no_content }
    end
  end

  
  def upload
    file = Uploader.upload(params[:file])
    @imported_rows = Carrier.from_file(file)
    if @imported_rows > 0
      redirect_to carriers_url, notice: "File '#{params[:file].original_filename}' succesfully imported. #{@imported_rows} new record(s) added"
    else                           
      redirect_to carriers_url, alert: "File '#{params[:file].original_filename}' not imported."
    end
  end   
  
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_carrier
      @carrier = Carrier.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def carrier_params
      params.require(:carrier).permit(:name, :is_customer, :is_supplier, :search_criteria, :q)
    end
end
