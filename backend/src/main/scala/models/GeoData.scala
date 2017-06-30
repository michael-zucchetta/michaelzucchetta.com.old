package models

import io.circe.{Decoder, Encoder}

case class GeoData(
                    ipAddress: String,
                    city: Option[String],
                    region: Option[String],
                    countryCode: Option[String],
                    countryName: Option[String]
                  )

object GeoData {
  implicit val decodeGeoData: Decoder[GeoData] =
    Decoder.forProduct5("geoplugin_request", "geoplugin_city", "geoplugin_region", "geoplugin_countryCode", "geoplugin_countryName")(GeoData.apply)

  implicit val encodeGeoData: Encoder[GeoData] =
    Encoder.forProduct5("ip_address", "city", "region", "country_code", "country_name") { geoData =>
      (geoData.ipAddress, geoData.city, geoData.region, geoData.countryCode, geoData.countryName)
    }
}
