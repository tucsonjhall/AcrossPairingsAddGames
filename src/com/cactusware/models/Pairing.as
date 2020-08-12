package com.cactusware.models {
	import mx.utils.UIDUtil;

	public class Pairing {
		
		public var GUID:String = UIDUtil.createUID();
		public var visitorIndex:int;
		public var homeIndex:int;
		
		public function Pairing() {
		}
	}
}
