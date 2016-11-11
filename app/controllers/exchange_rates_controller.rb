class ExchangeRatesController < ApplicationController
  before_action :set_exchange_rate, only: [:show, :edit, :update, :destroy]
  semantic_breadcrumb :index, :exchange_rates_path


  def index
  	s_filter = params[:q]
  	s_criteria = params[:search_criteria]
  	s_type = params[:search_type]
  	
  	@per_page = params[:per_page] || WillPaginate.per_page
  	  
    if s_filter
	  case s_type
		  when "contain"
			@exchange_rates = ExchangeRate.where.has { sql(s_criteria) =~ "%#{s_filter}%" }.paginate(:per_page => @per_page, :page => params[:page])
		  when "start"
			@exchange_rates = ExchangeRate.where.has { sql(s_criteria) =~ "#{s_filter}%" }.paginate(:per_page => @per_page, :page => params[:page])
		  else
			@exchange_rates = ExchangeRate.where.has { sql(s_criteria) == "#{s_filter}" }.paginate(:per_page => @per_page, :page => params[:page])
	  end
      
    else
      @exchange_rates = ExchangeRate.all.paginate(:per_page => @per_page, :page => params[:page])
    end
    
    respond_to do |format|
	  format.html
	  format.xls { send_data(@exchange_rates.to_a.to_xls(:except => [:created_at, :updated_at])) }
	  format.csv { send_data(@exchange_rates.to_a.to_csv(:except => [:created_at, :updated_at])) }
    end    
  end

  
  def new
    @exchange_rate = ExchangeRate.new
  end

  
  def edit
  	 semantic_breadcrumb @exchange_rate.name, exchange_rate_path(@exchange_rate)  	  
  end

  
  def create
    @exchange_rate = ExchangeRate.new(exchange_rate_params)

    if @exchange_rate.save
      redirect_to action: :index, notice: "'#{@exchange_rate.currency}' was successfully created."
    else
      render :new, alert: @exchange_rate.errors.full_messages  
    end
  end

  
  def update
    if @exchange_rate.update(exchange_rate_params)
      redirect_to exchange_rates_url, notice: "'#{@exchange_rate.currency}' was successfully updated."
    else
      render :edit, alert: @exchange_rate.errors.full_messages  
    end
  end

  def destroy
    @exchange_rate.destroy
    respond_to do |format|
      format.html { redirect_to exchange_rates_url, notice: "'#{@exchange_rate.currency}' was successfully deleted." }
      format.json { head :no_content }
    end
  end

  
  def upload
    file = Uploader.upload(params[:file])
    @imported_rows = ExchangeRate.delay.from_file(file, current_user.email)
    #if @imported_rows > 0
    #  redirect_to exchange_rates_url, notice: "File '#{params[:file].original_filename}' succesfully imported. #{@imported_rows} new record(s) added"
    #else                           
    #  redirect_to exchange_rates_url, alert: "File '#{params[:file].original_filename}' not imported."
    #end
    redirect_to exchange_rates_url, notice: "File '#{params[:file].original_filename}' will be imported in background"
  end   
  
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_exchange_rate
      @exchange_rate = ExchangeRate.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def exchange_rate_params
      params.require(:exchange_rate).permit(:start_date, :currency, :rate)
    end
end
