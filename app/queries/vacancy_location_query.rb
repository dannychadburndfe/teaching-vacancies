class VacancyLocationQuery < ApplicationQuery
  NATIONWIDE_LOCATIONS = ["england", "uk", "united kingdom", "britain", "great britain"].freeze

  attr_reader :scope

  include DistanceHelper

  def initialize(scope = Vacancy.live)
    @scope = scope
  end

  def call(location_query, radius_in_miles)
    normalised_query = location_query&.strip&.downcase
    radius = convert_miles_to_metres(radius_in_miles.to_i)

    if normalised_query.blank? || NATIONWIDE_LOCATIONS.include?(normalised_query)
      scope
    elsif LocationPolygon.include?(normalised_query)
      polygon = LocationPolygon.with_name(normalised_query)

      scope
        .joins("
          INNER JOIN location_polygons
          ON ST_DWithin(vacancies.geolocation, location_polygons.area, #{radius})
        ")
        .where("location_polygons.id = ?", polygon.id)
    else
      coordinates = Geocoding.new(normalised_query).coordinates

      # TODO: Geocoding class currently returns this on error, it should probably raise a
      # suitable error instead. Refactor later!
      return scope.none if coordinates == [0, 0]

      point = "POINT(#{coordinates.second} #{coordinates.first})"

      scope.where("ST_DWithin(geolocation, ?, ?)", point, radius)
    end
  end
end
