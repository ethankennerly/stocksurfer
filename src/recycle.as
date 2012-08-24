/* THought i needed this.  
Now I don't.
*/
			for (WaterSprite.next = 0; WaterSprite.next < WaterSprite.sectionBitmapDatas.length; WaterSprite.next ++ ) {
				waterGroup.add(WaterSprite.makeFlxSprite(WaterSprite.next));
			}
			//var sectionCount:int = int(Math.ceil(FlxG.width / Water.xPerPrice)) + 2;
			//waterGroup.maxSize = sectionCount;
		/* May recycle slice of water. */
			/*var wat:FlxSprite = waterGroup.members[0];
			while (! wat.onScreen()) {
				waterGroup.remove(wat);
				waterGroup.add(WaterSprite.makeFlxSprite(WaterSprite.next ++));
				wat = waterGroup.members[0];
			}*/

		public static function slicePixels(drawable:DisplayObject, xs:Vector.<int>):Vector.<BitmapData> {
			var bitmapDatas:Vector.<BitmapData> = new Vector.<BitmapData>();
			for (var i:int = 1; i < xs.length; i ++) {
				var x:int = xs[i-1];
				var width:int = xs[i] - x;
				var bitmapData:BitmapData = new BitmapData(width, drawable.height, true, 0x00000000);
				var clipRect:Rectangle = new Rectangle(x, 0, width, drawable.height);
				bitmapData.draw(drawable, null, null, null, clipRect, true);
				bitmapDatas.push(bitmapData);
			}
			return bitmapDatas;
		}

		/* Flixel instantiates reference to bitmap.  For dynamic pixels, overwrite with the copy. */
		public static function makeFlxSprite(next:int):FlxSprite {
			var bmp:BitmapData = WaterSprite.sectionBitmapDatas[next];
			BitmapBorg.setBitmapData(bmp, String(bmp));
			var sprite:FlxSprite = new FlxSprite(Water.xs[next], 0, BitmapBorg);
			sprite.solid = false;
			return sprite;
		}
			WaterSprite.next = 0;
			WaterSprite.sectionBitmapDatas = WaterSprite.slicePixels(this as DisplayObject, Water.xs);
			
		/*
		Bitmap data expects width and height less than 8192 pixels.
		Ethan expects water is wide and divided into sections.
		Ethan expects water has 366 or less sections.
		To conserve rendering, at any moment Ethan expects only a few visibleSections to appear.
		These from sections.  When a new section is needed, it recycles oldest.
		*/
		public static function testWaterSectionBitmaps():void {
			for (var s:String in prices.arrays) {
				prices.array = prices.arrays[s];
				FlxG.switchState( new PlayState() );
				if (! (2 <= Water.xs.length) ) {
					throw new Error("Expected water x ordinates longer than " + Water.xs.length.toString());
				}
				else if (! (Water.ys.length <= 366) ) {
					throw new Error("Expected water x ordinates shorter than " + Water.xs.length.toString());
				}
				var sectionCount:int = int(Math.ceil(FlxG.width / Water.xPerPrice)) + 2;
				var state:PlayState = FlxG.state as PlayState;
				if (! (sectionCount == state.waterGroup.length)) {
					throw new Error("Expected exactly " + sectionCount.toString() + " visibleSections, got " + state.waterGroup.length.toString());
				}
				if (! (sectionCount == state.waterGroup.maxSize)) {
					throw new Error("Expected exactly " + sectionCount.toString() + " max size of visibleSections, got " + state.waterGroup.maxSize.toString());
				}
				for (var v:int = 0; v < state.waterGroup.length; v++ ) {
					var section:FlxSprite = state.waterGroup.members[v];
					if (! (Water.xs[v] == section.x)) {
						throw new Error("Expected original section x at water " + Water.xs[v].toString() + ", got " + section.x.toString());
					}
					if (! (section.pixels == WaterSprite.sectionBitmapDatas[v])) {
						throw new Error("Expected original section pixels matches section bitmap at index " + v.toString());
					}
				}
				state.player.x = Water.xs[1];
				state.player.y = Water.ys[1];
				state.update();
				if (! (FlxG.width == state.waterGroup.members[0].x)) {
					throw new Error("Expected to recycle first visible section x to " + FlxG.width + ", got " + state.waterGroup.members[0].x.toString());
				}
				if (! (state.waterGroup.members[0].pixels == WaterSprite.sectionBitmapDatas[sectionCount])) {
					throw new Error("Expected recycled section pixels matches section bitmap at section count index " + sectionCount.toString());
				}
			}	
		}

			// BitmapBorg._bitmapData = waterImage.drawRectangle(FlxG.camera.scroll.x + FlxG.width, FlxG.camera.scroll.y + FlxG.height, FlxG.width, FlxG.height);
		
