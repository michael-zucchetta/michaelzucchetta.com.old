define [], () ->
	class Canvas
		constructor: (@canvasId) ->
			@_canvas = document.getElementById(@canvasId)
			@_scale = 1
			@_ctx = @_canvas.getContext "2d"
			_self = this
			document.addEventListener 'mousemove', (event) ->
				
				_self._mouseX = event.pageX - $(_self._canvas).offset().left
				_self._mouseY = event.pageY - $(_self._canvas).offset().top
				return	
		pixInterval = 4
		initCanvasWithImg: (img) ->
			@_img = img;
			@width = @_img.width*@_scale
			@height = @_img.height*@_scale
			@_canvas.width = @width
			@_canvas.height = @height
			@drawImage()
			return
		loadImage: (img) ->
			if (img instanceof Image)
				@initCanvasWithImg(img)
			else
				img.onload = @initCanvasWithImg(img)

			return
		drawImage: (action) ->
			@_ctx.clearRect(0, 0, @width*@_scale, @height*@_scale)
			@_ctx.save()
			action?()
			@_ctx.drawImage(@_img, 0, 0)
			@_pixels = @_ctx.getImageData(0, 0, @width*@_scale, @height*@_scale)
			@_ctx.restore()
			return
		getPixelValue: (y, x) ->
			offset = y*pixInterval*@_pixels.width + x*pixInterval
			return {
				r: @_pixels.data[offset + 0]
				g: @_pixels.data[offset + 1]
				b: @_pixels.data[offset + 2]
				opacity: @_pixels.data[offset + 3]
			}
		#zoom by a factor of 2 and use a cursor as center of the zoomed canvas
		zoomCanvas: () ->
			_self = this
			@drawImage () ->
				newY = _self._mouseY - _self.height/4
				newX = _self._mouseX - _self.width/4
				_self._scale *= 2
				console.log _self._mouseX, _self._mouseY, newX, newY
				_self._ctx.scale(_self._scale, _self._scale)
				_self._ctx.translate(-newX, -newY)
				return
			return
	return Canvas