package project.core.utils
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Linear;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	import flash.system.System;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;

	public final class EffectUtils
	{
		private static const _BrightTransform:ColorTransform = new ColorTransform(1, 1, 1, 1, 54, 54, 54);
		private static const _NormalTransfrom:ColorTransform = new ColorTransform();
		/**
		 * 使对象变亮/恢复
		 */
		public static function Brighten( obj:DisplayObject, on:Boolean=true ):void {
			if( obj!=null ) {
				obj.transform.colorTransform=on ? _BrightTransform : _NormalTransfrom;
			}
		}
		
		/**
		 * 让对象变色闪烁
		 */
		public static function FlashColor( obj:DisplayObject, times:int=6, color:uint=0x00ff00 ):void {
			if( times>0 ) {
				if( times%2==0 ) {
					TweenMax.to(obj, 0.7, {ease:Linear.easeNone,colorTransform:{tint:color, tintAmount:0.4}, onComplete:FlashColor, onCompleteParams:[obj, times-1, color]});
				} else {
					TweenMax.to(obj, 1, {ease:Linear.easeNone,colorTransform:{tint:color, tintAmount:0}, onComplete:FlashColor, onCompleteParams:[obj, times-1, color]});
				}
			}
		}
		/**
		 * 让对象发光闪烁
		 */
		public static function FlashObject( obj:DisplayObject, times:int=6, color:uint=0xFFCC00 ):void {
			if( times>0 ) {
				if( times%2==0 ) {
					TweenMax.to(obj, 0.7, {glowFilter:{color:color, alpha:1, blurX:20, blurY:20, strength:2, quality:1}, onComplete:FlashObject, onCompleteParams:[obj, times-1, color]});
				} else {
					TweenMax.to(obj, 1, {glowFilter:{color:color, alpha:0, blurX:0, blurY:0}, onComplete:FlashObject, onCompleteParams:[obj, times-1, color]});
				}
			}
		}
		
		/**
		 * 对TextField或UFormItem等数值内容显示对象改变内容，并对增加或减少显示相应的闪烁效果
		 */
		public static function UpdateValueLabel( lbl:Object, val:int, container:Object=null, autoSize:Boolean=true ):void
		{
			var txtProp:String = "text";
			var colorProp:String = "textColor";
			if( lbl.hasOwnProperty("Value") ) {
				txtProp = "Value";
				autoSize = false;
			} else if( lbl.hasOwnProperty("value") ) {
				txtProp = "value";
				autoSize = false;
			}
			if( lbl.hasOwnProperty("Color") ) {
				colorProp = "Color";
				autoSize = false;
			} else if( lbl.hasOwnProperty("color") ) {
				colorProp = "color";
				autoSize = false;
			}
			var eff:Boolean = lbl[txtProp]!="";
			var oldVal:int = int(lbl[txtProp]);
			if( !_EffectCache[lbl] && lbl[txtProp]==val.toString() ){
				return ;
			}
			//			lbl[txtProp] = val.toString();
			
			if( !eff) {
				lbl[txtProp] = val.toString();
				if( autoSize ) {
					lbl.width = lbl.textWidth+3;
				}
				if( container!=null ) {
					container.Refresh();
				}
				return ;
			}
			
			if( _EffectCache[lbl] ) {
				if( _EffectCache[lbl][4]==val ) {
					return ;
				}
				lbl[colorProp] = _EffectCache[lbl][2];
				lbl[txtProp] = _EffectCache[lbl][4];
				clearInterval( _EffectCache[lbl][0] );
				delete _EffectCache[lbl];
			}
			var oldColor:uint = lbl[colorProp];
			var newColor:uint = oldVal<val ? 0x00ff00 : 0xff0000; 
			
			_EffectCache[lbl] = [setInterval( PlayEffect, 100, lbl, container, autoSize ),9, oldColor, newColor, val, txtProp, colorProp];
		}
		private static var _EffectCache:Dictionary = new Dictionary();
		private static function PlayEffect( lbl:Object, container:Object, autoSize:Boolean ):void {
			_EffectCache[lbl][1]--;
			var txtProp:String = _EffectCache[lbl][5];
			var colorProp:String = _EffectCache[lbl][6];
			lbl[colorProp] = _EffectCache[lbl][ _EffectCache[lbl][1]%2+2 ];
			if( _EffectCache[lbl][1]==0 ) {
				clearInterval( _EffectCache[lbl][0] );
				lbl[txtProp] = _EffectCache[lbl][4];
				if( autoSize ) {
					lbl.width = lbl.textWidth+3;
				}
				delete _EffectCache[lbl];
				if( container!=null ) {
					container.Refresh();
				}
			}
		}
		/**
		 * 清除特效，如果是MovieClip会自动停止，如果是Loader会自动unload
		 * @param obj 特效对象
		 * @param autuRemove 自动移除，如果未指定container则调用parent.removeChild
		 * @param container  调用 container.removeChild() 移除特效
		 */
		public static function ClearEffect( obj:DisplayObject, autoRemove:Boolean=true, container:DisplayObjectContainer=null ):void {
			if( obj ) {
				if( obj is MovieClip ) {
					(obj as MovieClip).stop();
				} else if ( obj is Loader) {
					(obj as Loader).unload();
				}
//				if( obj is Bitmap ) {
//					(obj as Bitmap).bitmapData.dispose();
//				}
				if( container ) {
					container.removeChild( obj );
				} else if( autoRemove && obj.parent ) {
					obj.parent.removeChild( obj );
				}
				obj = null;
				System.gc();
			}
		}
	}
}