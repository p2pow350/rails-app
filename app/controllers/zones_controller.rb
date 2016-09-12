class ZonesController < ApplicationController
  before_action :set_zone, only: [:show, :edit, :update, :destroy]
  semantic_breadcrumb :index, :zones_path


  def index
  	s_filter = params[:q]
  	s_criteria = params[:search_criteria]
  	
  	@per_page = params[:per_page] || WillPaginate.per_page
  	  
    if s_filter
      @zones = Zone.where.has { sql(s_criteria) =~ "%#{s_filter}%" }.paginate(:per_page => @per_page, :page => params[:page])
    else
      @zones = Zone.all.paginate(:per_page => @per_page, :page => params[:page])
    end    
    
    respond_to do |format|
	  format.html
	  format.xls { send_data(@zones.to_xls(:except => [:created_at, :updated_at])) }
	  format.csv { send_data(@zones.to_csv(:except => [:created_at, :updated_at])) }
    end    
  end

  
  def new
    @zone = Zone.new
  end

  
  def edit
  	 semantic_breadcrumb @zone.name, zone_path(@zone)  	  
  end

  
  def create
    @zone = Zone.new(zone_params)

    if @zone.save
      redirect_to action: :index, notice: "'#{@zone.name}' was successfully created."
    else
      render :new, alert: @zone.errors.full_messages  
    end
  end

  
  def update
    if @zone.update(zone_params)
      redirect_to zones_url, notice: "'#{@zone.name}' was successfully updated."
    else
      render :edit, alert: @zone.errors.full_messages  
    end
  end

  def destroy
    @zone.destroy
    respond_to do |format|
      format.html { redirect_to zones_url, notice: "'#{@zone.name}' was successfully deleted." }
      format.json { head :no_content }
    end
  end

  
  def upload
    file = Uploader.upload(params[:file])
    @imported_rows = Zone.delay.from_file(file)
    #if @imported_rows > 0
    #  redirect_to zones_url, notice: "File '#{params[:file].original_filename}' succesfully imported. #{@imported_rows} new record(s) added"
    #else                           
    #  redirect_to zones_url, alert: "File '#{params[:file].original_filename}' not imported."
    #end
    redirect_to zones_url, notice: "File '#{params[:file].original_filename}' will be imported in background"
  end   
  
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_zone
      @zone = Zone.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def zone_params
      params.require(:zone).permit(:name, :search_criteria, :q)
    end
end
