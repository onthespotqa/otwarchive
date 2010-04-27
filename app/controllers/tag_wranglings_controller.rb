class TagWranglingsController < ApplicationController
  before_filter :check_user_status
	before_filter :check_permission

  def check_permission
    logged_in_as_admin? || permit?("tag_wrangler") || access_denied
  end

  def index
    @counts = {}
    [Fandom, Character, Pairing, Freeform].each do |klass|
      @counts[klass.to_s.downcase.pluralize.to_sym] = klass.unwrangled.count
    end
    unless params[:show].blank?
      params[:sort_column] = 'name' if !valid_sort_column(params[:sort_column], 'tag')
      params[:sort_direction] = 'ASC' if !valid_sort_direction(params[:sort_direction])
      sort = params[:sort_column] + " " + params[:sort_direction] 
      if sort.include?('suggested')
        sort = sort + ", name ASC"
      end
      if params[:show] == "fandoms"
        @media_names = Media.by_name.collect(&:name)
        @tags = Fandom.unwrangled.find(:all, :order => sort).paginate(:page => params[:page], :per_page => 50)       
      elsif params[:show] == "character_pairings"
        if params[:fandom_string]
          @fandom = Fandom.find_by_name(params[:fandom_string])
          if @fandom && @fandom.canonical?
            @tags = @fandom.children.by_type("Pairing").canonical.find(:all, :order => sort).paginate(:page => params[:page], :per_page => 50)
          else
            flash[:error] = "#{params[:fandom_string]} is not a canonical fandom."
          end
        end
      else
        klass = params[:show].classify.constantize        
        @tags = klass.unwrangled.with_related_tags("Fandom", sort).paginate(:page => params[:page], :per_page => 50)               
      end
    end
  end
  
  def wrangle
    params[:page] = '1' if params[:page].blank?
    params[:sort_column] = 'name' if !valid_sort_column(params[:sort_column], 'tag')
    params[:sort_direction] = 'ASC' if !valid_sort_direction(params[:sort_direction])
    options = {:show => params[:show], :page => params[:page], :sort_column => params[:sort_column], :sort_direction => params[:sort_direction]}
    unless params[:canonicals].blank?
      canonicals = Tag.find(params[:canonicals])
      canonicals.each do |tag|
        tag.update_attributes(:canonical => true)
      end
    end
    if params[:media] && !params[:selected_tags].blank?
      options.merge!(:media => params[:media])
      @media = Media.find_by_name(params[:media])
      @fandoms = Fandom.find(params[:selected_tags])
      @fandoms.each { |fandom| fandom.add_association(@media) }
    elsif params[:character_string] && !params[:selected_tags].blank?
      options.merge!(:character_string => params[:character_string], :fandom_string => params[:fandom_string])
      @character = Character.find_by_name(params[:character_string])
      if @character && @character.canonical?
        @tags = Tag.find(params[:selected_tags])
        @tags.each { |tag| tag.add_association(@character) }
        flash[:notice] = "#{@tags.length} pairings were wrangled to #{params[:character_string]}."
        redirect_to tag_wranglings_path(options) and return        
      else
        flash[:error] = "#{params[:character_string]} is not a canonical character."
        redirect_to tag_wranglings_path(options) and return     
      end
    elsif params[:fandom_string] && !params[:selected_tags].blank?
      options.merge!(:fandom_string => params[:fandom_string])
      @fandom = Fandom.find_by_name(params[:fandom_string])
      if @fandom && @fandom.canonical?
        @tags = Tag.find(params[:selected_tags])
        @tags.each { |tag| tag.add_association(@fandom) }
      else
        flash[:error] = "#{params[:fandom_string]} is not a canonical fandom."
        redirect_to tag_wranglings_path(options) and return     
      end
    end
    flash[:notice] = "Tags were successfully wrangled!"
    redirect_to tag_wranglings_path(options)            
  end
  
  def discuss
    @comments = Comment.find(:all, :conditions => {:commentable_type => 'Tag'}, :order => 'updated_at DESC').paginate(:page => params[:page])
  end

end