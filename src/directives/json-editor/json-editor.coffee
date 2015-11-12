define ['premain'], (app) ->
	app.directive 'jsonEditor', ['$sce', '$timeout', '$interval', ($sce, $timeout, $interval) ->
		restrict: 'E'
		scope:
			jsonText: '='
		templateUrl: '/directives/json-editor/json-editor.html'
		css: '/directives/json-editor/json-editor.css'
		link: (scope, element, attrs) ->
			display = $('#json-display')
			textarea = $('#json-input')
			container = $('.json-input-container')

			editorWidth = null
			#momentarily mocked
			editorHeight = 416
			colsNumber = null
			rowsNumber = null
			cellWidth = 8
			cellHeight = 16
			scope.editorStatusMatrix = null
			cellX = 0
			cellY = 0
			scope.carelPos = {
				left: 0,
				top: 0
			}

			scope.initJsonEditor = () ->
				editorWidth = display.outerWidth()
				colsNumber = Math.round(editorWidth/cellWidth)
				rowsNumber = Math.round(editorHeight/cellHeight)
				scope.editorStatusMatrix = new Array(rowsNumber)
				_.each scope.editorStatusMatrix, (el, $index) ->
					#inside the each loop, the new object is an undefined variable and does not maintain the reference
					el = scope.editorStatusMatrix[$index] = new Array(colsNumber)
					el.isNew = true
					el.id = "cell"+$index
					return
				return
	
			#To be moved to a class?		
			scope.clickEditor = ($event) ->
				# x/cellWidth I obtain the partial cell position, with round I get the cell number
				tmpX = $event.offsetX/cellWidth
				#tmpX = (tmpX + 1) is cellNumber? tmpX : tmpX + 1
				cellX = Math.round($event.offsetX/cellWidth)
				tmpY = ($event.target.offsetTop + $event.offsetY)/cellHeight
				#tmpY = if tmpY > 1 then tmpY - 1 else tmpY
				cellY = Math.round(tmpY)
				y = cellY*cellHeight
				cellText = scope.editorStatusMatrix[cellY].string
				if cellText
					if cellText.length < cellX
						cellX = cellText.length
					textarea.val cellText
				else cellX = 0
				x = cellX*cellWidth
				scope.carelPos.left = x
				scope.carelPos.top = y
				textarea.focus()
				return

			scope.insertCharacter = ($event) ->
				cell = $("#cell"+cellY)
				key = event.keyCode || event.charCode
				newChar = String.fromCharCode(key)
				#not del key and not newline
				if (key isnt 8 and key isnt 46 and key isnt 13)
					scope.carelPos.left += cellWidth
					#TBD scope.editorStatusMatrix[cellY][cellX] = newChar
					if (scope.editorStatusMatrix[cellY].isNew)
					
						scope.editorStatusMatrix[cellY].string = newChar
						scope.editorStatusMatrix[cellY].isNew = false
					else
						tmpString = scope.editorStatusMatrix[cellY].string
						scope.editorStatusMatrix[cellY].string = tmpString.substring(0, cellX) + newChar + tmpString.substring(cellX, tmpString.length)
					cellX++
				if (key is 13)
					#13 is newline
					scope.carelPos.left = 0
					scope.carelPos.top += cellHeight
					textarea.val('')
					scope.json = ""
					cellY++
				return

			scope.deleteCharacter = ($event) ->
				#needed to capture delete key
				$timeout () ->
					cellText = scope.editorStatusMatrix[cellY].string
					key = $event.keyCode || $event.charCode
					if( key isnt 8 and key isnt 46 )
						return
					#backspace case
					removedCharsNumber = cellText.length -  scope.json.length
					removedChars = cellText.substring(cellX - removedCharsNumber, cellX)
					newLinesNum = _.countBy removedChars, (char) ->
						return char is '\n'
					
					if (scope.editorStatusMatrix[cellY].string - removedCharsNumber) <= 0
						scope.editorStatusMatrix[cellY].string = ""
						scope.editorStatusMatrix[cellY].isNew = true
					else
						#concatenate two strings: one from zero to the cursor's position and then from the cursor's position to the end of the string
						scope.editorStatusMatrix[cellY].string = scope.json = cellText.substring(0, cellX - removedCharsNumber) + cellText.substring(cellX, cellText.length)
				
					cellY -= newLinesNum.true if newLinesNum.true
					scope.carelPos.top -= cellHeight*newLinesNum.true
					#the .false are the non newline chars
					scope.carelPos.left -= cellWidth*newLinesNum.false
					cellX -= newLinesNum.false
					if cellX < 0
						#if it is going out of the screen
						cellX = 0
					return
				return

			scope.initCursor = (cursorId) ->
				$interval( () ->
					scope.hideCursor = !scope.hideCursor
					return
				, 500)

			angular.element(document).ready () ->
				scope.initJsonEditor()
				scope.initCursor('cursor')
				
				return

			return
	]
	return
