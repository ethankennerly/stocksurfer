package
{

	import flash.display.InteractiveObject;
	import flash.display.MovieClip;
	import flash.net.URLLoader;
	import flash.ui.Mouse;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import org.flixel.*;
	import org.flixel.plugin.photonstorm.API.FlxKongregate;
	import fl.controls.ComboBox;
	
	/*
	LoadStockMovieClip compiled from swc.
	http://blog.log2e.com/2008/05/07/creating-a-swc-component-in-flashdevelop/	
	*/
	public class LoadState extends FlxState
	{
		public static var loadMc:*;
		public static var map:Water;
		public static var mapScale:Number = 
								// 1.0 / 64;  // small
								1.0 / 32;  // small
		public static var loadingPrices:Vector.<Number>;
		public static var loadStock:Function;
		
		override public function create():void
		{
			super.create();
			FlxG.mouse.hide();
			Mouse.show();			
			
			LoadState.loadMc = new LoadStockMovieClip();
			var tickerCbx:ComboBox = LoadState.loadMc.tickerCbx;
			tickerCbx = Market.populateTickerComboBox(tickerCbx);
			function enableLoadBtn(e:Event):void {
				var item:* = tickerCbx.selectedItem;
				if (null == item) {
					LoadState.loadMc.loadBtn.enabled = false;
					return;
				}
				LoadState.loadMc.loadBtn.enabled = true;
			}
			tickerCbx.addEventListener(Event.CHANGE, enableLoadBtn);
			LoadState.loadMc.cancelBtn.addEventListener(MouseEvent.CLICK, this.handleMenuState);
			LoadState.loadMc.cancelBtn.label = "CANCEL";
			LoadState.loadMc.loadBtn.enabled = false;
			LoadState.loadMc.loadBtn.addEventListener(MouseEvent.CLICK, this.preview);
			LoadState.loadMc.loadBtn.label = "PREVIEW";
			LoadState.loadMc.startBtn.enabled = false;
			LoadState.loadMc.startBtn.addEventListener(MouseEvent.CLICK, this.load);
			LoadState.loadMc.startBtn.label = "START";
			FlxG.stage.addChild(LoadState.loadMc);
		}

		/* When movie clip is destroyed, we lose focus.  So focus on canvas.
		*/
		override public function destroy():void {
			var preloader:Preloader = FlxG.stage.getChildAt(0) as Preloader;
			var sprite:InteractiveObject = preloader.getChildAt(0) as InteractiveObject;  
			sprite.focusRect = false;
			FlxG.stage.focus = sprite;
			if (null != LoadState.loadMc) {
				try {
					FlxG.stage.removeChild(LoadState.loadMc);
				}
				catch (err:ArgumentError) {
				}
				LoadState.loadMc.cancelBtn.removeEventListener(MouseEvent.CLICK, this.handleMenuState);
				LoadState.loadMc.loadBtn.removeEventListener(MouseEvent.CLICK, this.preview);
				LoadState.loadMc.startBtn.removeEventListener(MouseEvent.CLICK, this.load);
			}
			Mouse.hide();
			
			FlxG.mouse.show();
			super.destroy();
		}
		
		protected function handleMenuState(e:MouseEvent):void {
			FlxG.switchState(new MenuState());
		}

		/* Draw small scale map of the stock, centered at preview. */
		public static function drawPreview(prices:Vector.<Number>):void {
			var previewMc:MovieClip = LoadState.loadMc.previewMc;
			previewMc.visible = false;

			if (null != LoadState.map) {
				try {
					LoadState.loadMc.removeChild(LoadState.map);
				}
				catch (err:Error) {
				}
				LoadState.map = null;
			}
			LoadState.map = new Water(prices);
			LoadState.map.scaleX = LoadState.mapScale;
			LoadState.map.scaleY = LoadState.mapScale;
			var centeredLeft:int = int(previewMc.x - 0.5 * LoadState.map.width);
			var centeredTop:int = int(previewMc.y - 0.5 * LoadState.map.height);
			LoadState.map.x = centeredLeft;
			LoadState.map.y = centeredTop;
			LoadState.loadMc.addChild(LoadState.map);
		}
		
		/* Load stock from ticker combo box and draw small scale map of the stock. */
		protected function preview(e:MouseEvent):void {
			var tickerCbx:ComboBox = LoadState.loadMc.tickerCbx;
			var item:* = tickerCbx.selectedItem;
			if (null == item) {
				return;
			}
			var tickerSymbol:String = tickerCbx.value;
			LoadState.loadMc.startBtn.label = "LOADING " + tickerSymbol;
			LoadState.loadMc.startBtn.enabled = false;
			function logError(e:Event):void {
				FlxG.log("Cannot load stock " + tickerSymbol);
			}
			var stockLoader:URLLoader = Broker.loadStock(Config.crossdomainUrl, tickerSymbol, Broker.arrays, logError);
			function readyLevels(e:Event):void {
				stockLoader.removeEventListener(Event.COMPLETE, readyLevels);
				LoadState.loadingPrices = Broker.arrays[tickerSymbol];
				LoadState.drawPreview(LoadState.loadingPrices);
				LoadState.loadMc.startBtn.label = "START " + tickerSymbol;
				LoadState.loadMc.startBtn.enabled = true;
			}
			stockLoader.addEventListener(Event.COMPLETE, readyLevels);
		}

		/* Compatible with replay of this stock. */
		internal static function _loadStock(tickerSymbol:String, prices:Vector.<Number>):void {
			Broker.arrays[tickerSymbol] = prices;
			FlxG.levels[FlxG.level] = tickerSymbol;
		}
		
		/* Erase replay.  Goto menu. */
		protected function load(e:MouseEvent):void {
			var tickerCbx:ComboBox = LoadState.loadMc.tickerCbx;
			var tickerSymbol:String = tickerCbx.value;
			MenuState.initReplay();
			LoadState.loadStock(tickerSymbol, LoadState.loadingPrices);
			FlxG.switchState(new MenuState());
		}
	}
}

