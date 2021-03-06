class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :nearby, :results]


  def home
    @reviews = Review.best
  end

  def results
    skip_authorization
    @providers = Provider.all
    @reviews = Review.all
    @reviews = Review.global_search(params[:query]) if params[:query].present?
    @providers = @providers.global_search(params[:query]) if params[:query].present?
    @tags = []
    prov_ids = []

    if params[:category].present?
      params[:category].each do |category|
        prov_ids << ProviderCategory.where(category_id: category).pluck(:provider_id)
      end
      @providers = @providers.where(id: prov_ids.flatten.uniq)
      @providers.each do |provider|
        @tags << provider.tags
      end
      @tags = @tags.flatten.uniq
      @providers = @providers.where(id: prov_ids.flatten.uniq)
    end

    if params[:tag].present?
      params[:tag].each do |tag|
        prov_ids << ProviderTag.where(tag_id: tag).pluck(:provider_id)
      end
    @providers = @providers.where(id: prov_ids.flatten.uniq)
    end
    @providers = @providers.sort_by(&:avg_rating).reverse! if params["sort"]=="rating"

    @markers = @providers.map do |provider|
   if provider.latitude
      {
        lat: provider.latitude,
        lng: provider.longitude,
        infoWindow: render_to_string(partial: 'components/map_popup', locals: { provider: provider })

      }
    end

    end
  end

  def nearby
    @providers = policy_scope(Provider)
    if request.location
      result = request.location
      location = result.coordinates
    end
    location = Geocoder.search('Orchard Road, Singapore').first.coordinates if !location || location == []
    @providers = @providers.near(location, 1.5, units: :km)
    reviews = @providers.map do |provider|
      provider.reviews.each do |review|
        review
      end
    end
    @reviews = []
    @reviews = reviews.map do |r_arr|
      if r_arr[0] != []
        r_arr[0]
      end
    end
    @reviews.each do |r|
      if r == nil
        @reviews.delete(r)
      end
    end
    @favourite = Favourite.new
    @markers = @providers.map do |provider|
      {
        lat: provider.latitude,
        lng: provider.longitude,
        infoWindow: render_to_string(partial: 'components/map_popup', locals: { provider: provider })

      }
    end
  end

  def activity
    @likes = current_user.likes
    @favs = current_user.favourites
  end

  def results_tags
  end

end
