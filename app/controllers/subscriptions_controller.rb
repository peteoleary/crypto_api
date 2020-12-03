require 'httparty'

class SubscriptionsController < ApplicationController
  def scope
    Subscription
  end

  def validpairs
    render json: get_valid_pairs
  end

  def limits
    offlines = ['BTC']
    subs = Subscription.where(user_id: current_user.id)
    subs = subs.select {|sub|
      filtered_subs = offlines.select { | off |
        !sub.pair.include? off
      }
      filtered_subs.count > 0
    }
    limits = subs.map do |sub|
      response = HTTParty.get("https://www.ShapeShift.io/limit/#{sub.pair}")
      JSON.parse(response.body)
    end
    render json: limits
  end

  def create
    if get_valid_pairs.include? allow_params['pair']
      @object = scope.new(allow_params)
      @object.user_id = current_user.id if @object.respond_to? 'user_id'
      render_new
    else
      render json: {message: 'invalid pair'}, status: 422
      end
  end

  protected

  def offline_coins
    response = HTTParty.get("https://shapeshift.io/offlinecoins")
    JSON.parse(response.body)
  end

  def get_valid_pairs
    response = HTTParty.get("https://shapeshift.io/validpairs")
    response.body
  end

  # Only allow a trusted parameter "white list" through.
  def allow_params
    params.permit(:id, :user_id, :pair)
  end
end
