/**
 * Memory
 * 
 * A class with a few memory-management methods, as much as 
 * such a thing exists in a Flash player.
 * Copyright (c) 2007 Henri Torgemane
 * 
 * See LICENSE.txt for full license information.
 */
package com.hurlant.util
{
	import flash.system.System;
	
	public class Memory
	{
		public static function gc():void {
			// force a GC
		   System.gc();
		}
		public static function get used():uint {
			return System.totalMemory;
		}
	}
}