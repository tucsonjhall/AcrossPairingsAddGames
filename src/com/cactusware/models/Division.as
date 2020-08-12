package com.cactusware.models {
	import mx.utils.UIDUtil;

	public class Division {
		
		public var GUID:String = UIDUtil.createUID();
		public var teams:Array = new Array();
		public var name:String;
		public var acrossDivisions:Array = new Array();
		public var pairingIndices:Array = new Array();
		
		
		public function Division() {
		}
	}
}
