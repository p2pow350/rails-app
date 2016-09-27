class RatesController < ApplicationController
  before_action :set_rate, only: [:show, :edit, :update, :destroy]
  semantic_breadcrumb :index, :rates_path


  def index
  	s_filter = params[:q]
  	s_criteria = params[:search_criteria]
  	
  	@per_page = params[:per_page] || WillPaginate.per_page
  	  
    if s_filter
      @rates = Rate.where.has { sql(s_criteria) =~ "%#{s_filter}%" }.paginate(:per_page => @per_page, :page => params[:page])
    else
      @rates = Rate.all.paginate(:per_page => @per_page, :page => params[:page])
    end    
    
    respond_to do |format|
	  format.html
	  format.xls { send_data(@rates.to_a.to_xls(:except => [:created_at, :updated_at, :id])) }
	  format.csv { send_data(@rates.to_a.to_csv(:except => [:created_at, :updated_at, :id])) }
    end    
  end

  
  def new
    @rate = Rate.new
  end

  def generate
    
  end 
  
  def edit
  	 semantic_breadcrumb @rate.name, rate_path(@rate)  	  
  end

  
  def create
    @rate = Rate.new(rate_params)

    if @rate.save
      redirect_to action: :index, notice: "'#{@rate.name}' was successfully created."
    else
      render :new, alert: @rate.errors.full_messages  
    end
  end

  
  def update
    if @rate.update(rate_params)
      redirect_to rates_url, notice: "'#{@rate.name}' was successfully updated."
    else
      render :edit, alert: @rate.errors.full_messages  
    end
  end

  def destroy
    @rate.destroy
    respond_to do |format|
      format.html { redirect_to rates_url, notice: "'#{@rate.name}' was successfully deleted." }
      format.json { head :no_content }
    end
  end

  
  def upload
    file = Uploader.upload(params[:file])
    @imported_rows = Rate.delay.from_file(file, current_user.email, params[:carrier_id])
    # if @imported_rows > 0
    #   redirect_to rates_url, notice: "File '#{params[:file].original_filename}' succesfully imported. #{@imported_rows} new record(s) added"
    # else                           
    #   redirect_to rates_url, alert: "File '#{params[:file].original_filename}' not imported."
    # end
    
    redirect_to rates_url, notice: "File '#{params[:file].original_filename}' will be imported in background"
  end   
  
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_rate
      @rate = Rate.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def rate_params
      params.require(:rate).permit(:name, :prefix, :zone_id, :carrier_id, :search_criteria, :q)
    end
end
