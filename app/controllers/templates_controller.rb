class TemplatesController < ApplicationController
  before_action :set_template, only: [:show, :edit, :update, :destroy]
  semantic_breadcrumb :index, :templates_path


  def index
  	s_filter = params[:q]
  	s_criteria = params[:search_criteria]
  	s_type = params[:search_type]
  	
  	params[:per_page] = Template.count if params[:per_page] == 'All'
  	@per_page = params[:per_page] || WillPaginate.per_page
  	  
    if s_filter
	  case s_type
		  when "contain"
			@templates = Template.where.has { sql(s_criteria) =~ "%#{s_filter}%" }.paginate(:per_page => @per_page, :page => params[:page])
		  when "start"
			@templates = Template.where.has { sql(s_criteria) =~ "#{s_filter}%" }.paginate(:per_page => @per_page, :page => params[:page])
		  else
			@templates = Template.where.has { sql(s_criteria) == "#{s_filter}" }.paginate(:per_page => @per_page, :page => params[:page])
	  end
      
    else
      @templates = Template.all.paginate(:per_page => @per_page, :page => params[:page])
    end
    
    respond_to do |format|
	  format.html
	  format.xls { send_data(@templates.to_a.to_xls(:except => [:created_at, :updated_at])) }
	  format.csv { send_data(@templates.to_a.to_csv(:except => [:created_at, :updated_at])) }
    end    
  end

  
  def new
    @template = Template.new
  end

  
  def edit
  	 semantic_breadcrumb @template.name, template_path(@template)  	  
  end

  
  def create
    @template = Template.new(template_params)

    if @template.save
      redirect_to action: :index, notice: "'#{@template.name}' was successfully created."
    else
      render :new, alert: @template.errors.full_messages  
    end
  end

  
  def update
    if @template.update(template_params)
      redirect_to templates_url, notice: "'#{@template.name}' was successfully updated."
    else
      render :edit, alert: @template.errors.full_messages  
    end
  end

  def destroy
    @template.destroy
    respond_to do |format|
      format.html { redirect_to templates_url, notice: "'#{@template.name}' was successfully deleted." }
      format.json { head :no_content }
    end
  end

  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_template
      @template = Template.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def template_params
      params.require(:template).permit(:name, :header_rows, :sheet, :zone_col, :prefix_col, :price_col, :date_col)
    end
end
