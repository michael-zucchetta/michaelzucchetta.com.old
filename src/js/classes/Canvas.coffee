define [], () ->
	class Canvas
		constructor: (@canvasId) ->
			@_canvas = document.getElementById(@canvasId)
		pixInterval = 4
		initCanvasWithImg: (img) ->
			@width = img.width
			@height = img.height
			@_ctx = @_canvas.getContext("2d")
			@_ctx.drawImage(img, 0, 0)
			@_pixels = @_ctx.getImageData(0, 0, img.width, img.height)
			return
		loadImage: (img) ->
			if (img instanceof Image)
				@initCanvasWithImg(img)
			else
				img.onload = @initCanvasWithImg(img)

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
		zoomCanvas: (cursor) ->
			newX = cursor.x - @width/2
			newY = cursor.y - @height/2
			@_ctx.scale(2, 2)
			@_ctx.translate(newX, newY)
			return
	return Canvas
