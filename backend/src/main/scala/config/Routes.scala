package config

import fs2.Task
import io.circe._
import io.circe.syntax._
import io.circe.generic.extras.auto._
import io.circe.generic.extras.Configuration
import models.TrackingActionRequest
import org.http4s._
import org.http4s.dsl._
import org.http4s.circe._
import org.http4s.util.CaseInsensitiveString
import org.log4s.getLogger
import services.{AuthHandler, GeoPluginService, TrackingService}

import scalaoauth2.provider.AuthorizationRequest

case class Routes(geoPluginService: GeoPluginService, trackingService: TrackingService) {
  implicit val config: Configuration = Configuration.default.withSnakeCaseKeys
  private[this] val logger = getLogger

  private def returnResult[T](resultEither: Either[Response, T])(implicit encoder: Encoder[T]): Task[Response] =
    resultEither match {
      case Right(correctResult) =>
        Ok(correctResult.asJson)
      case Left(status) =>
        Task.now(status)
    }


  def routes(request: Request): Task[MaybeResponse] = request match {
    case req@GET -> Root / "get_geo_data" =>
      val ipAddress = req.params.get("ip_address").getOrElse("")
      for {
        resultEither <- geoPluginService.getGeoLocalizationByIp(ipAddress)
        response <- returnResult(resultEither)
      } yield response
    case req@POST -> Root / "track_action" =>
      for {
        trackingActionRequest <- req.as(jsonOf[TrackingActionRequest])
        ipAddress = trackingActionRequest.ipAddress.getOrElse("")
        geoDataEither <- geoPluginService.getGeoLocalizationByIp(ipAddress)
        result <- Task.delay( geoDataEither.map( geoData => trackingService.trackAccessAction(trackingActionRequest, geoData, req.headers.get(CaseInsensitiveString("referer"))).unsafeRun() ) )
        response <- returnResult(result)
      } yield response
    case req@POST -> Root / "auth" =>
      // will use http4s authedservice
      import scala.concurrent.ExecutionContext.Implicits.global
      implicit val strategy = Config.strategy
      for{
        authResult <- Task.fromFuture(services.AuthService().handleRequest(new AuthorizationRequest(Map.empty[String, Seq[String]], Map.empty[String, Seq[String]]), AuthHandler()))
        response <- NotImplemented("yet")
      } yield {
        logger.info(s"${authResult}")
        response
      }

      // issueAccessToken(services.AuthService)
    case req =>
      logger.warn(s"rout not found for $req")
      NotFound("Not found")
  }

  def websiteService: HttpService = Service {
    case req =>
      val host = req.headers.get(CaseInsensitiveString("host"))
      logger.info(s"Host is $host")
      routes(req)
  }
}