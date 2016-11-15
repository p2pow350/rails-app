class CodesController < ApplicationController
  before_action :set_code, only: [:show, :edit, :update, :destroy]
  semantic_breadcrumb :index, :codes_path


  def index
  	s_filter = params[:q]
  	s_criteria = params[:search_criteria]
  	s_type = params[:search_type]
  	
  	unless params[:per_page]=='All' 
  		@per_page = params[:per_page] || WillPaginate.per_page 
  	else
  		@per_page = 1000000000000
  	end
  	  
    if s_filter
	  case s_type
		  when "contain"
			@codes = Code.includes(:zone).where.has { sql(s_criteria) =~ "%#{s_filter}%" }.paginate(:per_page => @per_page, :page => params[:page])
		  when "start"
			@codes = Code.includes(:zone).where.has { sql(s_criteria) =~ "#{s_filter}%" }.paginate(:per_page => @per_page, :page => params[:page])
		  else
			@codes = Code.includes(:zone).where.has { sql(s_criteria) == "#{s_filter}" }.paginate(:per_page => @per_page, :page => params[:page])
	  end
      
    else
      @codes = Code.all.includes(:zone).paginate(:per_page => @per_page, :page => params[:page])
    end
    
    respond_to do |format|
	  format.html
	  format.xls { send_data(@codes.to_a.to_xls(:except => [:created_at, :updated_at])) }
	  format.csv { send_data(@codes.to_a.to_csv(:except => [:created_at, :updated_at])) }
    end    
    
  end
  
  def new
    @code = Code.new
  end

  
  def edit
  	 semantic_breadcrumb @code.name, code_path(@code)  	  
  end

  
  def create
    @code = Code.new(code_params)

    if @code.save
      redirect_to action: :index, notice: "'#{@code.name}' was successfully created."
    else
      render :new, alert: @code.errors.full_messages  
    end
  end

  
  def update
    if @code.update(code_params)
      redirect_to codes_url, notice: "'#{@code.name}' was successfully updated."
    else
      render :edit, alert: @code.errors.full_messages  
    end
  end

  def destroy
    @code.destroy
    respond_to do |format|
      format.html { redirect_to codes_url, notice: "'#{@code.name}' was successfully deleted." }
      format.json { head :no_content }
    end
  end

  
  def upload
    file = Uploader.upload(params[:file])
    @imported_rows = Code.delay.from_file(file, current_user.email)
    # if @imported_rows > 0
    #   redirect_to codes_url, notice: "File '#{params[:file].original_filename}' succesfully imported. #{@imported_rows} new record(s) added"
    # else                           
    #   redirect_to codes_url, alert: "File '#{params[:file].original_filename}' not imported."
    # end
    
    redirect_to codes_url, notice: "File '#{params[:file].original_filename}' will be imported in background"
  end   
  
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_code
      @code = Code.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def code_params
      params.require(:code).permit(:name, :prefix, :zone_id)
    end
end
