import Constants from 'js/services/Constants';
import 'js/services/file-utilities';

class ImagesUtilities {

	constructor(private $q, private $interval, private FilesUtilities) {
	}
	
	public loadImage(file, callback) {
		this.FilesUtilities.loadFile(file).then((resolvedFile) => {
			let img = this.createImage(resolvedFile.target.result);
			this.onCompleteImg(img).then(() =>callback(img));
		});
	}
		
	public onCompleteImg(img) {
		let deferred = this.$q.defer();
		let cancelInterval = this.$interval(() => {
			if (img.complete) {
				this.$interval.cancel(cancelInterval);
				deferred.resolve(true);
			}
		}, 30);	
		return deferred.promise;
	}

	public createImage(hash) {
		let image = new Image();
		image.src = hash;
		return image;
	}
	
	public floatOpacity(opacity: number): number {
		return opacity/255;
	}
	
	public calculateVal(val, opacity) {
		let hexVal;
		if (val*opacity) {
			hexVal = (val*opacity).toString(16);
		}
		if(!hexVal) {
			return '00';
		}
		if(hexVal.length === 1) {
			return '0' + hexVal;
		}
		return hexVal
	}
	
	public fromRgbToHex(point) {
		let opacity = this.floatOpacity(point.opacity);
		return '#' + this.calculateVal(point.r, opacity) + this.calculateVal(point.g, opacity) + this.calculateVal(point.b, opacity);
	}
}

let imagesUtilitiesFactory = ($q, $interval, FilesUtilities) => {
	return new ImagesUtilities($q, $interval, FilesUtilities);
}

export default angular.module(Constants.MAIN_MODULE)
	.factory('ImagesUtilities', imagesUtilitiesFactory);
