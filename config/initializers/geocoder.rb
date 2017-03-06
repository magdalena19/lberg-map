Geocoder.configure(
  # Geocoding options
  # timeout: 3,                 # geocoding service timeout (secs)
  # lookup: :google,            # name of geocoding service (symbol)
  # language: :en,              # ISO-639 language code
  # use_https: false,           # use HTTPS for lookup requests? (if supported)
  # http_proxy: nil,            # HTTP proxy server (user:pass@host:port)
  # https_proxy: nil,           # HTTPS proxy server (user:pass@host:port)
  # api_key: nil,               # API key for geocoding service
  # cache: nil,                 # cache object (must respond to #[], #[]=, and #keys)
  # cache_prefix: 'geocoder:',  # prefix (string) to use for all cache keys

  # Calculation options
  # units: :mi,                 # :km for kilometers or :mi for miles
  # distances: :linear          # :spherical or :linear

  # Nominatim (:nominatim)
  # API key: none
  # Quota: 1 request/second
  # Region: world
  # SSL support: no
  # Languages: ?
  # Documentation: http://wiki.openstreetmap.org/wiki/Nominatim
  # Terms of Service: http://wiki.openstreetmap.org/wiki/Nominatim_usage_policy
  # Limitations: Please limit request rate to 1 per second and include your contact information in User-Agent headers (eg: Geocoder.configure(:http_headers => { "User-Agent" => "your contact info" })). Data licensed under Open Database License (ODbL) (you must provide attribution).

  # geocoding service (see below for supported options):
  lookup: :nominatim,
  timeout: 5,
  units: :km,
  use_https: true
)
