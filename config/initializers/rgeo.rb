require 'rgeo/active_record'

RGeo::ActiveRecord::SpatialFactoryStore.instance.tap do |config|
  # Set the default factory for spatial columns
  config.default = RGeo::Geographic.spherical_factory(srid: 4326)

  # Optionally, configure specific factories for certain types
  # config.register(RGeo::Geographic.spherical_factory(srid: 4326), geo_type: 'point')
end
