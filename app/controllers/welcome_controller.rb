class WelcomeController < ApplicationController

  def index
    @expires = 24.hours.from_now.to_i
  end

end
