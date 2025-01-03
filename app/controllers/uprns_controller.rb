# app/controllers/uprns_controller.rb
class UprnsController < ApplicationController
  def show
    # Find the UprnGeo record by the provided UPRN parameter
    uprn_geo = UprnGeo.find_by(uprn: params[:uprn])

    if uprn_geo && uprn_geo.geom
      # Extract latitude and longitude from the geometry point
      latitude = uprn_geo.geom.y
      longitude = uprn_geo.geom.x

      # Render the coordinates as JSON
      render json: { uprn: uprn_geo.uprn, latitude: latitude, longitude: longitude }
    else
      # Render an error message if the record is not found or geom is nil
      render json: { error: 'UPRN not found or geometry data is missing' }, status: :not_found
    end
  end

  def index
    # Validate presence of required parameters
    unless params[:min_lat] && params[:max_lat] && params[:min_lng] && params[:max_lng]
      return render json: { error: 'Missing bounding box parameters' }, status: :bad_request
    end

    # Query UPRNs within the bounding box, limit to 100 results
    uprns = UprnGeo.where(
      "ST_Within(geom, ST_MakeEnvelope(?, ?, ?, ?, 4326))",
      params[:min_lng].to_f,
      params[:min_lat].to_f,
      params[:max_lng].to_f,
      params[:max_lat].to_f
    ).limit(100)

    # Return array of UPRN points with coordinates
    render json: uprns.map { |u| 
      {
        uprn: u.uprn,
        latitude: u.geom.y,
        longitude: u.geom.x
      }
    }
  end
end
