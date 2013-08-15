/*****************************************************
*  
*  Copyright 2009 Adobe Systems Incorporated.  All Rights Reserved.
*  
*****************************************************
*  The contents of this file are subject to the Mozilla Public License
*  Version 1.1 (the "License"); you may not use this file except in
*  compliance with the License. You may obtain a copy of the License at
*  http://www.mozilla.org/MPL/
*   
*  Software distributed under the License is distributed on an "AS IS"
*  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
*  License for the specific language governing rights and limitations
*  under the License.
*   
*  
*  The Initial Developer of the Original Code is Adobe Systems Incorporated.
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2009 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/
package player.osmfexpansion
{
	import flash.events.DRMErrorEvent;
	import flash.events.DRMStatusEvent;
	import flash.events.Event;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.drm.DRMVoucher;
	
	import org.osmf.events.DVRStreamInfoEvent;
	import org.osmf.events.LoaderEvent;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.metadata.Metadata;
	import org.osmf.metadata.MetadataNamespaces;
	import org.osmf.net.DynamicStreamingResource;
	import org.osmf.net.NetLoader;
	import org.osmf.net.NetStreamLoadTrait;
	import org.osmf.net.NetStreamSwitchManager;
	import org.osmf.net.NetStreamSwitchManagerBase;
	import org.osmf.net.StreamingURLResource;
	import org.osmf.net.SwitchingRuleBase;
	import org.osmf.net.httpstreaming.*;
	import org.osmf.net.httpstreaming.dvr.DVRInfo;
	import org.osmf.net.httpstreaming.dvr.HTTPStreamingDVRCastDVRTrait;
	import org.osmf.net.httpstreaming.dvr.HTTPStreamingDVRCastTimeTrait;
	import org.osmf.net.httpstreaming.f4f.HTTPStreamingF4FFileHandler;
	import org.osmf.net.httpstreaming.f4f.HTTPStreamingF4FIndexHandler;
	import org.osmf.net.rtmpstreaming.DroppedFramesRule;
	import org.osmf.traits.LoadState;
	
	import player.events.NNetTargetEvent;
	
	
	/**
	 * HTTPStreamingNetLoader is a NetLoader that can load HTTP streams.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class CustomHTTPStreamingNetLoader extends HTTPStreamingNetLoader
	{
		/**
		 * Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function CustomHTTPStreamingNetLoader()
		{
			// Connection sharing and custom NetConnectionFactory classes are
			// irrelevant for HTTP streaming connections, hence we don't allow
			// the client to pass those params in.
			super();
		}
		
		public function get httpNetStream():HTTPNetStream {
			return _httpNetStream;
		}
		
		/**
		 * @private
		 */
		private var _httpNetStream:HTTPNetStream;
		
		// For OSMF 2.0
		override protected function createNetStream(connection:NetConnection, resource:URLResource):NetStream
		{
			var factory:HTTPStreamingFactory = createHTTPStreamingFactory();
			_httpNetStream = new HTTPNetStream(connection, factory, resource);
			return _httpNetStream;
		}
		
	}
}