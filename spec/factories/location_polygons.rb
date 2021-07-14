FactoryBot.define do
  factory :location_polygon do
    name { "London" }
    location_type { "cities" }
    buffers do
      {
        "1" => [[51.46822890300007, -0.564208123999947]],
        "5" => [[51.47012161100008, -0.6364669129999356]],
        "10" => [[51.47621236300006, -0.7085774819999529]],
        "15" => [[51.46822890300007, -0.564208123999947]],
        "20" => [[51.46822890300007, -0.564208123999947]],
        "25" => [[51.47944372100005, -0.7807775579999543]],
        "30" => [[51.46822890300007, -0.564208123999947]],
        "35" => [[51.46822890300007, -0.564208123999947]],
        "40" => [[51.46822890300007, -0.564208123999947]],
        "45" => [[51.46822890300007, -0.564208123999947]],
        "50" => [[51.48267548200005, -0.8529853679999633]],
        "55" => [[51.46822890300007, -0.564208123999947]],
        "60" => [[51.46822890300007, -0.564208123999947]],
        "65" => [[51.46822890300007, -0.564208123999947]],
        "70" => [[51.46822890300007, -0.564208123999947]],
        "80" => [[51.46822890300007, -0.564208123999947]],
        "90" => [[51.46822890300007, -0.564208123999947]],
        "100" => [[51.49267548200005, -0.8629853679999633]],
        "200" => [[51.50267548200005, -0.8729853679999633]],
      }
    end
  end
end
