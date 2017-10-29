class RecipesController < ApplicationController
  def index
    @recipes = Recipe.all
  end

  def show
    @recipe = Recipe.find(params[:id])
  end

  def new
    @recipe = Recipe.new
    @recipe.ingredients.build # build ingredient attributes, nothing new here
  end

  def create
    @recipe = Recipe.new(params[:recipe])
    if params[:add_ingredient]
      # add empty ingredient associated with @recipe
      @recipe.ingredients.build
    elsif params[:remove_ingredient]
      # nested model that have _destroy attribute = 1 automatically deleted by rails
    else
      # save goes like usual
      if @recipe.save
        flash[:notice] = "Successfully created recipe."
        redirect_to @recipe and return
      end
    end
    render :action => 'new'
  end

  def edit
    @recipe = Recipe.find(params[:id])
  end

  def update
    @recipe = Recipe.find(params[:id])
    if params[:add_ingredient]
    	# rebuild the ingredient attributes that doesn't have an id
    	unless params[:recipe][:ingredients_attributes].blank?
	  for attribute in params[:recipe][:ingredients_attributes]
	    @recipe.ingredients.build(attribute.last.except(:_destroy)) unless attribute.last.has_key?(:id)
	  end
    	end
      # add one more empty ingredient attribute
      @recipe.ingredients.build
    elsif params[:remove_ingredient]
      # collect all marked for delete ingredient ids
      removed_ingredients = params[:recipe][:ingredients_attributes].collect { |i, att| att[:id] if (att[:id] && att[:_destroy].to_i == 1) }
      # physically delete the ingredients from database
      Ingredient.delete(removed_ingredients)
      flash[:notice] = "Ingredients removed."
      for attribute in params[:recipe][:ingredients_attributes]
      	# rebuild ingredients attributes that doesn't have an id and its _destroy attribute is not 1
        @recipe.ingredients.build(attribute.last.except(:_destroy)) if (!attribute.last.has_key?(:id) && attribute.last[:_destroy].to_i == 0)
      end
    else
      # save goes like usual
      if @recipe.update_attributes(params[:recipe])
        flash[:notice] = "Successfully updated recipe."
        redirect_to @recipe and return
      end
    end
    render :action => 'edit'
  end

  def destroy
    @recipe = Recipe.find(params[:id])
    @recipe.destroy
    flash[:notice] = "Successfully destroyed recipe."
    redirect_to recipes_url
  end
end
