package  
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	/**
	Parse CSV text, convert arrays to CSV text.
	Load file, save file.
	 * @author Ethan Kennerly
	 */
	public class Csv 
	{
		
		static public var fileTypes:Array = [new FileFilter("Comma-separated values file", "*.csv")];
		static public var defaultFileName:String = "input.csv";
		
		/* Flash security restricts one file operation at a time, so only one callback is needed. 
		Unfortunately, event listening has strict event signature that prevents passing additional arguments. 
		*/
		static protected var onOpenCompleteParseContents:Function;
		
		/* Flash security restricts one file operation at a time, so only one callback is needed. 
		Unfortunately, event listening has strict event signature that prevents passing additional arguments. 
		*/
		static protected var onSaveCompleteCallback:Function;
		static internal var _file:FileReference;
		
		// Copied from org.flixel.system.debug.VCR {{{
		
		/**
		 * Opens the file dialog and registers event handlers for the file dialog.
		 */
		static public function open(parseContents:Function = null, fileTypes:Array = null):void
		{
			Csv.onOpenCompleteParseContents = parseContents;
			if (null == fileTypes) {
				fileTypes = Csv.fileTypes;
			}
			_file = new FileReference();
			_file.addEventListener(Event.SELECT, onOpenSelect);
			_file.addEventListener(Event.CANCEL, onOpenCancel);
			_file.browse(fileTypes);
		}
		
		/**
		 * Called when a file is picked from the file dialog.
		 * Attempts to load the file and registers file loading event handlers.
		 * 
		 * @param	E	Flash event.
		 */
		static protected function onOpenSelect(E:Event=null):void
		{
			_file.removeEventListener(Event.SELECT, onOpenSelect);
			_file.removeEventListener(Event.CANCEL, onOpenCancel);
			
			_file.addEventListener(Event.COMPLETE, onOpenComplete);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onOpenError);
			_file.load();
		}
		
		/**
		 * Called when a file is opened successfully.
		 * If there's stuff inside, then the contents are loaded into a new replay.
		 *
		 * @param	E	Flash Event.
		 */
		static protected function onOpenComplete(E:Event=null):void
		{
			_file.removeEventListener(Event.COMPLETE, onOpenComplete);
			_file.removeEventListener(IOErrorEvent.IO_ERROR, onOpenError);
			
			//Turn the file into a giant string
			var fileContents:String = null;
			var data:ByteArray = _file.data;
			if(data != null)
				fileContents = data.readUTFBytes(data.bytesAvailable);
			_file = null;
			if((fileContents == null) || (fileContents.length <= 0))
			{
				trace("ERROR: Empty file.");
				return;
			}
			
			if (null != Csv.onOpenCompleteParseContents) {
				Csv.onOpenCompleteParseContents(fileContents);
				Csv.onOpenCompleteParseContents = null;
			}
		}
		
		/**
		 * Called if the open file dialog is canceled.
		 * 
		 * @param	E	Flash Event.
		 */
		static protected function onOpenCancel(E:Event=null):void
		{
			_file.removeEventListener(Event.SELECT, onOpenSelect);
			_file.removeEventListener(Event.CANCEL, onOpenCancel);
			_file = null;
		}
		
		/**
		 * Called if there is a file open error.
		 * 
		 * @param	E	Flash Event.
		 */
		static protected function onOpenError(E:Event=null):void
		{
			_file.removeEventListener(Event.COMPLETE, onOpenComplete);
			_file.removeEventListener(IOErrorEvent.IO_ERROR, onOpenError);
			_file = null;
			trace("ERROR: Unable to open CSV.");
		}
		
		/**
		 * Called when the user presses the red record button.
		 * Stops the current recording, opens the save file dialog, and registers event handlers.
		 */
		static public function save(data:String, saveCallback:Function = null, defaultFileName:String = ""):void
		{
			Csv.onSaveCompleteCallback = saveCallback;
			if (null == defaultFileName) {
				defaultFileName = Csv.defaultFileName;
			}
			if((data != null) && (data.length > 0))
			{
				_file = new FileReference();
				_file.addEventListener(Event.COMPLETE, onSaveComplete);
				_file.addEventListener(Event.CANCEL,onSaveCancel);
				_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
				_file.save(data, defaultFileName);
			}
		}
		
		/**
		 * Called when the file is saved successfully.
		 * 
		 * @param	E	Flash Event.
		 */
		static protected function onSaveComplete(E:Event=null):void
		{
			_file.removeEventListener(Event.COMPLETE, onSaveComplete);
			_file.removeEventListener(Event.CANCEL,onSaveCancel);
			_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file = null;
			trace("Saved CSV.");
			if (null != onSaveCompleteCallback) {
				onSaveCompleteCallback();
				Csv.onSaveCompleteCallback = null;
			}
		}
		
		/**
		 * Called when the save file dialog is cancelled.
		 * 
		 * @param	E	Flash Event.
		 */
		static protected function onSaveCancel(E:Event=null):void
		{
			_file.removeEventListener(Event.COMPLETE, onSaveComplete);
			_file.removeEventListener(Event.CANCEL,onSaveCancel);
			_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file = null;
		}
		
		/**
		 * Called if there is an error while saving the gameplay recording.
		 * 
		 * @param	E	Flash Event.
		 */
		static protected function onSaveError(E:Event=null):void
		{
			_file.removeEventListener(Event.COMPLETE, onSaveComplete);
			_file.removeEventListener(Event.CANCEL,onSaveCancel);
			_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file = null;
			trace("ERROR: problem saving CSV.");
		}
		
		// }}}
	}

}