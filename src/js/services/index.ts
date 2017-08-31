import Constants from './constants';
import RestProxy from './rest-proxy';
import DaoFacade from './dao-facade';
import Session from './session';
import FileUtilities from './file-utilities';
import BasicInfoDao from './basic-info-dao';
import Auth from './auth';
import ImageUtilities from './image-utilities';
import AuthInterceptor from './auth-interceptor';
import PostsDao from './posts';

export default angular.module(Constants.SERVICE_MODULE, ['ui.router', DaoFacade,
				BasicInfoDao, FileUtilities, Session, ImageUtilities, RestProxy, Auth, AuthInterceptor, PostsDao])
	.name;
