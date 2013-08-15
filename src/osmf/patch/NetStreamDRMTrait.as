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
// Rustem EQUAL
package osmf.patch {
	import me.scriptor.additional.api.IDisposable;

	import org.osmf.events.DRMEvent;
	import org.osmf.events.MediaError;
	import org.osmf.traits.DRMTrait;

	import flash.events.DRMStatusEvent;
	import flash.system.SystemUpdater;

	[ExcludeClass]
	/**
	 * @private
	 * 
	 * NetStream-specific DRM trait.
	 */
	public class NetStreamDRMTrait extends DRMTrait implements IDisposable {
		private var _drmServices : DRMServices;
		/**
		 * @private
		 */
		private var isCreated : Boolean;

		/**
		 * Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function NetStreamDRMTrait(autoCreate : Boolean = true) {
			super();
			autoCreate && this.create();
		}

		public function create() : void {
			if (!this.isCreated) {
				this.drmServices.addEventListener(DRMEvent.DRM_STATE_CHANGE, this.onStateChange);
				this.isCreated = true;
			}
		}

		override public function dispose() : void {
			super.dispose();
			if (this.isCreated) {
				this.isCreated = false;
			}
		}

		public function set customToken(arg1 : String) : void {
			this.drmServices.customToken = arg1;
		}

		/**
		 * Data used by the flash player to implement DRM specific content protection.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function set drmMetadata(value : Object) : void {
			if (value != this.drmServices.drmMetadata) {
				this.drmServices.drmMetadata = value;
			}
		}

		public function get drmServices() : DRMServices {
			return this._drmServices ||= new DRMServices();
		}

		public function get drmMetadata() : Object {
			return this.drmServices.drmMetadata;
		}

		/**
		 * Calls the System Updater's update function
		 * @private
		 */
		public function update(type : String) : SystemUpdater {
			return this.drmServices.update(type);
		}

		/**
		 * @private
		 */
		override public function authenticate(username : String = null, password : String = null) : void {
			this.drmServices.authenticate(username, password);
		}

		/**
		 * @private
		 */
		override public function authenticateWithToken(token : Object) : void {
			this.drmServices.authenticateWithToken(token);
		}

		/**
		 * @private
		 * Signals failures from the DRMsubsystem not captured though the 
		 * DRMServices class.
			 
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function inlineDRMFailed(error : MediaError) : void {
			this.drmServices.inlineDRMFailed(error);
		}

		/**
		 * @private
		 * Signals DRM is available, taken from the inline netstream APIs.
		 * Assumes the voucher is available.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function inlineOnVoucher(event : DRMStatusEvent) : void {
			this.drmServices.inlineOnVoucher(event);
		}

		// Internals
		//
		private function onStateChange(event : DRMEvent) : void {
			this.setPeriod(event.period);
			this.setStartDate(event.startDate);
			this.setEndDate(event.endDate);
			this.setDrmState(event.drmState);
			this.dispatchEvent(new DRMEvent(DRMEvent.DRM_STATE_CHANGE, drmState, false, false, this.startDate, this.endDate, this.period, event.serverURL, event.token, event.mediaError));
		}
	}
}
