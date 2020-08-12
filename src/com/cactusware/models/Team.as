package com.cactusware.models {
	import mx.utils.UIDUtil;

	public class Team {
		
		public var GUID:String = UIDUtil.createUID();
		public var name:String;
		public var pairingIndexForAcross:int = -1;
		
		public function Team() {
		}
	}
}
