package player.subtitles
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	import org.osmf.metadata.CuePoint;
	import org.osmf.metadata.CuePointType;
	import org.osmf.metadata.TimelineMetadata;
	//import flash.events.IOErrorEvent;
	//import flash.events.SecurityErrorEvent;
	
	public class SubtitlesHandler extends EventDispatcher
	{
		public static const SUBTITLES_LOADED:String = ".subtitles.loaded";
		private var _SRTLoader:URLLoader = null;
		private var _eventType:String = null;

		public function SubtitlesHandler():void
		{
			_SRTLoader = new URLLoader();
		}
		
		public function loadSubtitles(_sub:String, _uri:String):void
		{
			_eventType = _sub + SUBTITLES_LOADED;
			_SRTLoader.addEventListener(Event.COMPLETE,                    loadSRT_Complete,      false, 0, true);
			_SRTLoader.addEventListener(Event.OPEN,                        loadSRT_Open,          false, 0, true);
			_SRTLoader.addEventListener(ProgressEvent.PROGRESS,            loadSRT_Progress,      false, 0, true);
			_SRTLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loadSRT_SecurityError, false, 0, true);
			_SRTLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS,       loadSRT_HTTP_Status,   false, 0, true);
			_SRTLoader.addEventListener(IOErrorEvent.IO_ERROR,             loadSRT_IO_Error,      false, 0, true);
			_SRTLoader.dataFormat = URLLoaderDataFormat.TEXT;
			_SRTLoader.load(new URLRequest(_uri));
		}
		
		private function loadSRT_Complete(e:Event):void
		{
			if(ExternalInterface.available) ExternalInterface.call("console.log", "loadSRT_Complete");
			dispatchEvent(new Event(_eventType));
		}
		
		private function loadSRT_Open(e:Event):void
		{
			if(ExternalInterface.available) ExternalInterface.call("console.log", "loadSRT_Open");
		}
		
		private function loadSRT_Progress(e:Event):void
		{
			if(ExternalInterface.available) ExternalInterface.call("console.log", "loadSRT_Progress");
		}
		
		private function loadSRT_SecurityError(e:Event):void
		{
			if(ExternalInterface.available) ExternalInterface.call("console.log", "loadSRT_SecurityError");
		}
		
		private function loadSRT_HTTP_Status(e:Event):void
		{
			if(ExternalInterface.available) ExternalInterface.call("console.log", "loadSRT_HTTP_Status");
		}
		
		private function loadSRT_IO_Error(e:Event):void
		{
			if(ExternalInterface.available) ExternalInterface.call("console.log", "loadSRT_IO_Error");
		}
		
		public function parseSRT(tmd:TimelineMetadata):void
		{
			var blocks : Array;
			var rn:uint = 1;
			blocks = _SRTLoader.data.split(/^[0-9]+$/gm);
			for each (var block : String in blocks)
			{
				var ln:uint = 0;
				var valid:Boolean = true;
				var start:Number;
				var end:Number;
				var dur:Number;
				var text:String = "";
				var lines:Array;
				
				lines = block.split(/['\n''\r']/);
				for each (var line : String in lines)
				{
					//all lines in a translation block
					var tline:String = trim(line);
					if(tline != "")
					{
						if(ln == 0)
							/*{
							// Record number line
							if(rn != Number(tline))
							{
							// Wrong record number
							trace("Warning (srt): wrong record order " + tline + " vs " + rn);
							valid = false;
							}
							rn++;
							}
							else if(ln == 1)*/
						{
							//timecodes line
							var timecodes : Array = line.split(/ +\-\-\> +/);
							start = stringToSeconds(timecodes[0]);
							end = stringToSeconds(timecodes[1]);
							dur = end - start;
							if(dur <= 0)
							{
								trace("Error (srt): inverse duration");
								valid = false;
							}
						}
						else
						{
							//translation line
							if(ln > 1)
								tline = "\n" + tline;
							text += tline;
						}
						ln++;
					}
				}
				if(ln > 2 && valid)
				{
					// Store sub
					tmd.addMarker(new CuePoint(CuePointType.ACTIONSCRIPT, start, "", [text], dur));
					rn++;
					CONFIG::SUBLINES
					{
						if(ExternalInterface.available) ExternalInterface.call("console.log", "Parse SRT: added \"" + text + "\"");
					}
				}
			}
			if(ExternalInterface.available) ExternalInterface.call("console.log", "Parse SRT: " + rn + " records");
		}
		
		public static function trim(p_string : String) : String
		{
			if (p_string == null)
			{
				return '';
			}
			return p_string.replace(/^\s+|\s+$/, '');
		}
		
		public static function stringToSeconds(string : String) : Number
		{
			var arr : Array = string.split(/[\:\,]/);
			var sec : Number = 0;
			if(arr.length == 4)
			{
				sec = 3600*Number(arr[0]) + 60*Number(arr[1]) + Number(arr[2]) + 0.001*Number(arr[3])
			}
			return sec;
		}
		
	}
	
}
