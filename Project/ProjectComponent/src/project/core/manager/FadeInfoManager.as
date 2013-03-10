package project.core.manager
{
    import com.greensock.TweenLite;
    
    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.Sprite;
    import flash.geom.Point;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.utils.Dictionary;
    import flash.utils.getTimer;
    import flash.utils.setTimeout;
    
    import project.core.global.GlobalVariables;
    import project.core.text.IText;
    import project.core.utils.Filters;

    public final class FadeInfoManager
    {
        public static var Root:DisplayObjectContainer;
		private static var _FadeTable:Dictionary;
		private static const ERROR_COLOR:uint = 0xff0000;
		private static const NORMAL_COLOR:uint = 0x66ff33;
//        public static const ALPHA_STEP:Number = 0.01;

        public static function Init():void
        {
			if(!Root)
			{
	            Root = new Sprite();
				Root.mouseChildren = false;
				Root.mouseEnabled = false;
	            GlobalVariables.RootParent.addChild( Root );
				_FadeTable = new Dictionary();
			}
        }
		
		/**
		 * 显示文本
		 * @text 要显示的文本
		 * @error 是否显示错误的颜色
		 * @point 需要显示的位置
		*/
		public static function Show(text:String, error:Boolean = false, point:Point = null, forceCenter:Boolean=true):void
		{
			var color:uint = error ? ERROR_COLOR : NORMAL_COLOR;
			
			ShowText(text, point, color, null, forceCenter);
		}
		
		/**
		 * 弹出文本显示
		 * @text 要显示的文本
		 * @point 显示的位置，默认在中间显示
		 * @color 显示的颜色
		 * @textFormat 文本的格式
		*/
		public static function ShowText(text:String, point:Point = null, color:uint = 0x66ff33, textFormat:TextFormat = null, forceCenter:Boolean=true):void
		{
			var label:TextField = new TextField();
			label.height = 21;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.filters = [Filters.TextGlow];
			if(textFormat)
			{
				label.text = text;
				label.setTextFormat(textFormat);
			}
			else
			{
				label.htmlText = "<font color='#" + color.toString(16) + "'>" + text + "</font>";
			}
			
			ShowDisplay(label, point, 3, forceCenter);
		}
		
		public static function ShowHtmlText(htmlText:String,point:Point = null,textFormat:TextFormat = null, forceCenter:Boolean=true):void
		{
			var label:TextField = new TextField();
			label.height = 21;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.filters = [Filters.TextGlow];
			label.htmlText = htmlText;
			ShowDisplay(label, point, 3, forceCenter);
		}
		
		public static function ShowHyperText( text:IText, params:Object=null, point:Point = null, time:int = 3, forceCenter:Boolean=true, fmt:TextFormat=null ):void {
			var lbl:TextField = new TextField();
			text.ToTextField(lbl,null,fmt,params);
			ShowDisplay( lbl, point, time, forceCenter );
		}
		
		/**
		 * @child 需要显示的对象
		*/
        public static function ShowDisplay(child:DisplayObject, point:Point = null, time:int = 3, forceCenter:Boolean=true):void
        {
            var infoLabel:Sprite = new Sprite();
            var bitmapData:BitmapData = new BitmapData( child.width, child.height, true, 0x0 );
            bitmapData.draw( child );
            infoLabel.graphics.clear();
            infoLabel.graphics.beginBitmapFill( bitmapData );
            infoLabel.graphics.drawRect( 0, 0, child.width, child.height );
            infoLabel.graphics.endFill();
			infoLabel.mouseChildren = false;
			infoLabel.mouseEnabled = false;
			
			var roll:Boolean = false;
            if ( point==null )
            {
				if( forceCenter ) {
                	point= new Point(( GlobalVariables.StageWidth - child.width )/2, (GlobalVariables.StageHeight - child.height)/2);
					roll = true;
				} else {
					point = new Point( GlobalVariables.CurrStage.mouseX+20, GlobalVariables.CurrStage.mouseY );
				}
//                if ( Root.numChildren == 0 )
//                {
//                    point.y = (GlobalVariables.StageHeight - child.height)/2;
//                }
//                else
//                {
//                    point.y = Root.getChildAt( Root.numChildren-1 ).y-child.height-10;
//                }
            }
			if( point.x + child.width > GlobalVariables.StageWidth ) {
				point.x += GlobalVariables.StageWidth-(point.x + child.width);
			}
			if( point.y + child.height > GlobalVariables.StageHeight ) {
				point.y += GlobalVariables.StageHeight-(point.y + child.height);
			}
            infoLabel.x = point.x;
            infoLabel.y = point.y;
			infoLabel.width = child.width;
			infoLabel.height = child.height;
			infoLabel.mouseChildren = false;
			infoLabel.mouseEnabled = false;
//			if(Root.numChildren == 0)
//			{
//				infoLabel.y = (pointY == 0?(GlobalVariables.StageHeight - child.height)/2:pointY);
//			}else
//			{
//				infoLabel.y = (pointY == 0?Root.getChildAt(Root.numChildren-1).y-child.height-10:pointY);
//			}
			if( roll ) {
				infoLabel.name = "roll_"+getTimer();
				hitTest(infoLabel);
			}
            Root.addChild( infoLabel );
			
			setTimeout( FadeTimer_OnTimer, time*1000, infoLabel );
//            var fadeTimer:Timer = new Timer( 100, time );
//			_FadeTable[fadeTimer] = infoLabel;
//			
//            fadeTimer.addEventListener( TimerEvent.TIMER, FadeTimer_OnTimer );
//            fadeTimer.addEventListener( TimerEvent.TIMER_COMPLETE, FadeTimer_OnComplete );
//            fadeTimer.start();
        }

		
		private static function FadeTimer_OnTimer( child:DisplayObject ):void {
			TweenLite.to( child, 2, {alpha:0, onComplete:FadeTimer_OnComplete, onCompleteParams:[child]} );
		}
		private static function FadeTimer_OnComplete( child:DisplayObject ):void {
			if( child.parent ) {
				child.parent.removeChild( child );
			}	
		}
//        private static function FadeTimer_OnTimer( event:TimerEvent ):void
//        {
//			var timer:Timer = event.currentTarget as Timer;
//			var child:DisplayObject = _FadeTable[timer];
//			
//			if(child)
//			{
//            	child.alpha -= 1/timer.repeatCount;
//			}
//        }

//        private static function FadeTimer_OnComplete( event:TimerEvent ):void
//        {
//			var timer:Timer = event.currentTarget as Timer;
//			var child:DisplayObject = _FadeTable[timer];
//			
//			if(child)
//			{
//				if(Root.contains(child))
//				{
//					Root.removeChild(child);
//				}
//			}
//			
//			
//			delete _FadeTable[timer];
//			timer.addEventListener(TimerEvent.TIMER, FadeTimer_OnTimer);
//			timer.addEventListener(TimerEvent.TIMER_COMPLETE, FadeTimer_OnComplete);
//			timer = null;
//            
//            event.currentTarget.stop();
//        }
		
		private static function hitTest(obj:DisplayObject):void
		{
			var child:DisplayObject;
			
			for(var i:int = Root.numChildren-1; i>=0;i--)
			{
				child = Root.getChildAt(i);
				if( child.name.indexOf("roll_")!=-1 ) {
					child.y -= obj.height;
					
					if( child.y<0 ) {
						TweenLite.killTweensOf(child);
						Root.removeChild( child );
					}
				}
			}			
		}
		
    }
}