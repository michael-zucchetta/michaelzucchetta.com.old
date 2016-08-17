package auth

import be.objectify.deadbolt.scala.AuthenticatedRequest
import be.objectify.deadbolt.scala.models.Subject

import scala.concurrent.ExecutionContext.Implicits.global
import scala.concurrent.Future

class MyUserlessDeadboltHandler extends MyDeadboltHandler {
  override def getSubject[A](request: AuthenticatedRequest[A]): Future[Option[Subject]] = Future(None)
}
