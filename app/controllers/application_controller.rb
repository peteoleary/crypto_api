class ApplicationController < ActionController::API
  before_action :set_object, only: [:show, :update, :destroy]

  # NOTE: shut down unauthenticated access to ALL /api endpoints except a few
  # that are explicitly exposed such as POST /user
  before_action :authenticate_user!

  def authenticate_user!
    raise 'requires token' unless request.headers['Authorization']
    token_parts = request.headers['Authorization'].split(' ')
    @current_user = User.find_by token: token_parts[1]
    raise 'unauthorzied' unless @current_user
    raise 'token expired' unless DateTime.now < @current_user.token_expiration
  end

  def current_user
    @current_user
  end

  def filtered_scope
    if scope.method_defined? :user_id and current_user
      scope.where(user_id: current_user.id)
    else
      scope
    end
  end

  def index
    @objects = filtered_scope.all
    render json: @objects, params: allow_params
  end

  def show
    access_control can_show? do
      render json: @object
    end
  end


  def create
    @object = scope.new(allow_params)
    @object.user_id = current_user.id if @object.respond_to? 'user_id'
    render_new
  end

  def update
    access_control can_edit? do
      render_update allow_params
    end
  end

  # NOTE: the basic level of permission in ownership represented by user_id in some objects
  def can_show?
    can_edit?
  end

  def can_edit?
    (@object.respond_to?('user_id') && @object.user_id == current_user.id) || (@object.class.name == 'User' && current_user.id == @object.id)
  end

  def access_control which_permission, &block
    if which_permission
      yield
    else
      render json: {message: 'not allowed'}, status: 401
    end
  end

  def search
    @objects = filtered_scope.find_by(allow_params)
    render json: @objects
  end

  def destroy
    access_control can_edit? do
      @object.destroy
    end
  end

  protected

  def render_update update_params
    if @object.update!(update_params)
      render json: @object
    else
      render json: @object.errors, status: :unprocessable_entity
    end
  end

  def render_new
    if @object.save
      render json: @object, status: :created
    else
      render json: @object.errors, status: :unprocessable_entity
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_object
    @object = scope.find(allow_params[:id])
  end

  def allow_params
    nil
  end
end
