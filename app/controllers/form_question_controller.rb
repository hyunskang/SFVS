class FormQuestionController < ApplicationController

  def show
    @form_type = params[:type]
    @list_of_questions = FormQuestion.get_questions_for_form(@form_type)
  end

  def save_progress
    @user = User.find(params[:id])
    @questions_list = FormQuestion.get_list_of_questions(params[:type])
    @form_content = {
      params[:type] => Hash[@questions_list.zip get_answers]
    }
    @application = @user.get_most_recent_application

    if params[:commit] == "Save and Return"
      update_application(false)
      flash[:notice] = "#{params[:type]} successfully saved."
      redirect_to user_path(@user)
    elsif params[:commit] == 'Submit'
      submit
    end
  end

  private
  #filter that check if the form is filled correctly
  def form_completed?
  	!(@form_content[params[:type]].has_value?("") || @form_content[params[:type]].has_value?(nil))
  end
  
  # Form an array of answers using the params
  def get_answers
    answers_list = []
    params[:form_answer].each do |key, value|
      answers_list << value
    end
    answers_list
  end

  def update_application(completed)
    @form_content[params[:type]][:completed] = completed
    @application.add_content(@form_content)
  end

  def submit
    if form_completed?
        update_application(true)
        flash[:notice] = "Submitted #{params[:type]}"
        redirect_to user_path(@user)
      else
        # Need to find a way to keep the values in the fields
        flash[:alert] = "There are missing fields in the form"
        @list_of_questions = FormQuestion.get_questions_for_form(params[:type])
        @form_type = params[:type]
        render :show
      end
  end
end
