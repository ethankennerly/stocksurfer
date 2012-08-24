/*
http://flixel.org/forums/index.php?topic=2425.msg14831#msg14831

	
Re: MovieClips in Flixel??
« Reply #2 on: Wed, Sep 22, 2010 »
Quote
Ah what a coincidence, this sound just like my development setup as well (my artist made the animation in flash), here is my code that turn MovieClip in to tilesets BitmapData, internally.


*/
//- package org.flixel
package
{
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.flixel.FlxObject;
	import org.flixel.FlxBasic; //+
	import org.flixel.FlxCamera; //+
	import org.flixel.FlxG; //+
	import org.flixel.FlxPoint; //+
	import org.flixel.FlxU; //+
	//import quad.utils.MovieClipCache;
	
	/**
	 * ...
	 * @author Achmad Aulia Noorhakim
	 */
	public class FlxMovieClip extends FlxObject
	{
		private var _delta	 :Number	 = 0;
		private var _timer	 :Number	 = 0;
		private var _frame	 :uint	   = 1;
		private var _playing   :Boolean	= true;
		private var _onFinish  :Function   = null;
		private var _loop	  :int		= -1;
		
		
		private var mcBuffer   :BitmapData = null;
		private var frmRect	:Array	  = [];
		private var bounds	 :Array	  = [];
		private var renderPt   :Point	  = new Point();
		
		
		public  var flipH	  :Boolean	= false;
		public  var totalFrames:int		= 0;
		//+ Width and height of a sprite, to conveniently loadGraphic.  
		// same name as FlxSprite, which is also commented as read-only yet is public.
		public  var frameWidth:int				= 0;
		public  var frameHeight:int				= 0;
		
		public function get frame():int { return _frame; }
		public function set frame(v:int):void
		{
			if (_frame != v)
			{
				_frame = (v % totalFrames) + 1;
			}
		}

		//----------------------------------------------------------------------------------------
		
		public function FlxMovieClip(MovieClipClass:Class, X:Number = 0, Y:Number = 0, fps:uint = 30)
		{
			super(X, Y);
			
			/**
			 * You could just replace this with new MovieClipClass();
			 */
			//- var mc:MovieClip = MovieClipCache.instance.getMovieClip(MovieClipClass);
			var mc:MovieClip = new MovieClipClass();
			
			/**
			 * find the biggest boundary
			 */
			var b:Rectangle = null;
			//- var w:int	   = 0;
			//- var h:int	   = 0;
			var i:int	   = 0; //+
			
			for (i = 1; i <= mc.totalFrames; ++i)
			{
				mc.gotoAndStop(i);
				b = mc.getBounds(mc);
				if (b.width  > frameWidth) frameWidth = b.width;
				if (b.height > frameHeight) frameHeight = b.height;
			}
			
			/**
			 * create the bitmapData to hold mc
			 */
			var key:String = String(MovieClipClass);
			if (!FlxG.checkBitmapCache(key))
				buildBuffer(mc, key, frameWidth, frameHeight);
			else
				mcBuffer = FlxG.createBitmap(0, 0, 0, false, key);
			

			for (var j:int = 0; j < 2; ++j)
				for (i = 0; i < mc.totalFrames; ++i)
				{
					mc.gotoAndStop(i + 1);
					bounds [ j * mc.totalFrames + i ] = mc.getBounds(mc);
					frmRect[ j * mc.totalFrames + i ] = new Rectangle(i * frameWidth, j * frameHeight, frameWidth, frameHeight);
				}
					
			totalFrames = mc.totalFrames;
			_delta	  = 1 / fps;
		}
		
		
		private function buildBuffer(mc:MovieClip, key:String, w:int, h:int):void
		{
			var b:Rectangle = null;				// boundary
			var m:Matrix	= new Matrix;		// transform matrix
			var f:Boolean   = false;			// flip flag
			var t:int	   = mc.totalFrames;	// total frames
			
			mcBuffer = FlxG.createBitmap(w * t, h * 2, 0x00000000, false, key);
			
			for (var j:int = 0; j < 2; ++j)
			{
				f	= (j == 1);
				
				// identity matrix
				m.a  = 1; m.b  = 0;
				m.c  = 0; m.d  = 1;
				m.tx = 0; m.ty = 0;
				
				// scale matrix
				m.a *= (f ? -1 : 1);
				m.d *= 1.0;
				
				for (var i:int = 0; i < t; ++i)
				{
					mc.gotoAndStop(i + 1);
					b = mc.getBounds(mc);
					
					// translate matrix
					m.tx = i * w - b.x + (f ? b.width + (b.x * 2) : 0);
					m.ty = j * h - b.y;
					
					mcBuffer.draw(mc, m);
				}
				
			}
			
		}
		
		
		public function play(loop:int = -1, onFinish:Function = null, randFrame:Boolean = false):void
		{
			_playing  = true;
			_onFinish = onFinish;
			_loop	 = loop;
			frame	 = (randFrame ? Math.random() * (totalFrames - 1) + 1 : 1);
		}
		
		public function stop():void
		{
			_playing = false;
			_frame   = 1;
		}
		
		public function pause():void
		{
			_playing = false;
		}
		
		override public function update():void
		{
			super.update();
			
			if (_playing == false)
				return;
			
			_timer += FlxG.elapsed;
			while (_timer >= _delta)
			{
				_timer -= _delta;
				_frame  = (_frame % totalFrames) + 1;
				if (_frame == 1)
				{
					if (_loop > 0)
					{
						_loop -= 1;
						if (_loop == 0)
						{
							stop();
							if (_onFinish != null)
								_onFinish();
								
							break;
						}
						
					}
					
				}
				
			}
			
			var frmIdx:int = getFrameIndex();
			width	  = bounds[ frmIdx ].width  + bounds[ frmIdx ].x * 2;
			height	 = bounds[ frmIdx ].height + bounds[ frmIdx ].y * 2;
		}
		
		
		private function getFrameIndex():uint
		{
			return _frame - 1 + (flipH ? totalFrames : 0);
		}
		
		
		public function render():void
		{
			getScreenXY(_point);
			
			var frmIdx:int = getFrameIndex();
			renderPt.x	 = _point.x + bounds[ frmIdx ].x;
			renderPt.y	 = _point.y + bounds[ frmIdx ].y;
			FlxG.camera.buffer.copyPixels(mcBuffer, frmRect[ frmIdx ], renderPt, null, null, true);
		}
		
	override public function overlaps(ObjectOrGroup:FlxBasic,InScreenSpace:Boolean=false,Camera:FlxCamera=null):Boolean
		{
			getScreenXY(_point);

			var fr:int = getFrameIndex();
			var tx:Number = _point.x + bounds[ fr ].x;
			var ty:Number = _point.y + bounds[ fr ].y;
			if(! ObjectOrGroup is FlxMovieClip) {
				return super.overlapsAt(tx, ty, ObjectOrGroup, InScreenSpace, Camera);
			}
			var tw:Number = width;
			var th:Number = height;
			
			var o:FlxObject = ObjectOrGroup as FlxObject;
			o.getScreenXY(_point);
			var ox:Number = _point.x;
			var oy:Number = _point.y;
			var ow:Number = o.width;
			var oh:Number = o.height;
			
			if(o is FlxMovieClip)
			{
				var fmc:FlxMovieClip = FlxMovieClip(o);
				ox += fmc.bounds.x;
				oy += fmc.bounds.y;
			}
			
			if ((ox <= tx - ow) ||
				(ox >= tx + tw) ||
				(oy <= ty - oh) ||
				(oy >= ty + th))
			{
				return false;
			}
			
			return true;
		}
		
	override public function overlapsPoint(Point:FlxPoint,InScreenSpace:Boolean=false,Camera:FlxCamera=null):Boolean
		{
			getScreenXY(_point);

			var fr:int = getFrameIndex();
			var tx:Number = _point.x + bounds[ fr ].x;
			var ty:Number = _point.y + bounds[ fr ].y;
			var ObjectOrGroup:FlxObject = new FlxObject(Point.x, Point.y);
			return super.overlapsAt(tx, ty, ObjectOrGroup, InScreenSpace, Camera);
		}
		
		override public function destroy():void
		{
			super.destroy();
			
			mcBuffer   = null;
			frmRect	= null;
			renderPt   = null;
			bounds	 = null;
			
			_frame	 = 0;
			_timer	 = 0;
			_delta	 = 0;
			_playing   = false;
		}
		
		
		public function getBitmapData():BitmapData {
			return mcBuffer;
		}
		/**
		 * Safely access bitmap data.
		 */
		public function get bitmapData():BitmapData
		{
			return mcBuffer;
		}
		
		/**
		 * @private
		 */
		private function set bitmapData(data:BitmapData):void
		{
			mcBuffer = data;
		}
	}

}

