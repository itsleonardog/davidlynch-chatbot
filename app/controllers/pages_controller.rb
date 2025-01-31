class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home, :why_login ]

  def home
  end

  def why_login
  end
end
