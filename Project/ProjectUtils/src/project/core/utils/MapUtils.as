package project.core.utils
{
	import flash.display.Bitmap;
	import flash.display.Graphics;
	import flash.geom.Point;

	public final class MapUtils
	{
		//---------------- 战斗地图参数 ---------------------------------//
		public static const TILE_WIDTH:int = 76;
		public static const TILE_HEIGHT:int = 46;
		public static const TILE_RATE:Number = TILE_HEIGHT / TILE_WIDTH;
		public static const TILE_WIDTH_HALF:Number = TILE_WIDTH*0.5;
		public static const TILE_HEIGHT_HALF:Number = TILE_HEIGHT*0.5;
		public static const TILE_WIDTH_DOUBLE:int = TILE_WIDTH*2;
		public static const TILE_HEIGHT_DOUBLE:int = TILE_HEIGHT*2;
		public static const TILE_MAP_WIDTH:int = TILE_WIDTH * 12;
		public static const TILE_MAP_HEIGHT:int = TILE_HEIGHT * 12;
		/**
		 * 取坐标所在网格的中心点
		 */
		public static function GetTileCenterByPos(p:Point):Point
		{
			p = GetTileXYByPos(p.x, p.y);
			return GetPosByTileXY(p.x, p.y);
		}

		/**
		 * 将屏幕坐标转换成网格坐标
		 */
		public static function GetTileXYByPos(sx:int, sy:int):Point
		{
			var n:Number = (sx)/TILE_WIDTH;
			var m:Number = (sy-TILE_MAP_HEIGHT*0.5)/TILE_HEIGHT;
			var tx:int=int((n - m) < 0 ? n-m-1 : n-m)// + _maxY;
        	var ty:int=int((n + m) < 0 ? n+m-1 : n+m);
			return new Point( tx, ty );
		}
		/**
		 * 将网格坐标转换成屏幕坐标
		 */
		public static function GetPosByTileXY(tx:int, ty:int):Point
		{
			return new Point( int((tx+ty+1)*TILE_WIDTH_HALF), int( ( ty - tx ) * TILE_HEIGHT_HALF )+TILE_MAP_HEIGHT*0.5 );
		}
		
		public static function GetDirection( x:Number, y:Number, dx:Number, dy:Number):Number {
			/*
			 * 公式round( 8 * ( atan(relX/relY) / (2*PI) ) )
			 * atan(relX/relY) -- 取x,y夹角
			 * 除以 2*PI -- 得到夹角在圆周(360`)中的百分比
			 * 乘以8四舍五入(round) -- 得到角在八等分圆周中的位置。东＝0,东南＝1,南＝2,西南＝3,西＝4/-4,西北＝-3,北＝-2,东北＝-1
			 */
			return Math.round(Math.atan2(dy - y, dx - x) * 4 / Math.PI);
		}
		/**
		 * 多边形面积
		 */
		public static function PolyArea(poly:Array):Number
		{
			if (poly.length < 3)
				return 0;
			var num:int=poly.length;
			var sum:Number=0;
			var m:int=1;
			for (; ; m++, num--)
			{
				if (num < 3)
					break;
				var r1:Point=new Point(poly[m].x - poly[0].x, poly[m].y - poly[0].y);
				var r2:Point=new Point(poly[m + 1].x - poly[m].x, poly[m + 1].y - poly[m].y);
				sum+=r1.x * r2.y - r2.x * r1.y;
			}
			return sum > 0 ? sum / 2 : -sum / 2;
		}

		/**
		 * 弧度转角度
		 */
		public static function RadiansToDegrees(radians:Number):Number
		{
			var degrees:Number=radians * (180 / Math.PI);
			return degrees;
		}

		/**
		 * 角度转弧度
		 */
		public static function DegreesToRadians(degrees:Number):Number
		{
			var radians:Number=degrees * (Math.PI / 180);
			return radians;
		}

		/**
		 * 取两点间距离
		 */
		public static function GetDistance(x1:Number, y1:Number, x2:Number, y2:Number):Number
		{
			var x:Number=x1 - x2;
			var y:Number=y1 - y2;
			return Math.sqrt(x * x + y * y);
		}

		/**
		 * 两个矩形是否相交
		 */
		public static function CrossRect( xmin1:Number, ymin1:Number, xmax1:Number, ymax1:Number,
										  xmin2:Number, ymin2:Number, xmax2:Number, ymax2:Number):Boolean
		{
			var m:Boolean=(xmin1 > xmax2) || (xmax1 < xmin2);
			var n:Boolean=(ymin1 > ymax2) || (ymax1 < ymin2);

			return !(m || n);
		}

		//返回true 为相交，false为不相交 
		public static function LineIntersect(ps:Point, pe:Point, p:Point):Number
		{
			return ((pe.x - ps.x) * (p.y - ps.y) - (p.x - ps.x) * (pe.y - ps.y));
		}

		public static function CrossLine(p1:Point, p2:Point, p3:Point, p4:Point):Boolean
		{
			if (Math.max(p1.x, p2.x) >= Math.min(p3.x, p4.x) && Math.max(p3.x, p4.x) >= Math.min(p1.x, p2.x) && Math.max(p1.y, p2.y) >= Math.min(p3.y, p4.y) && Math.max(p3.y, p4.y) >= Math.min(p1.y, p2.y) && LineIntersect(p1, p2, p3) * LineIntersect(p1, p2, p4) <= 0 && LineIntersect(p3, p4, p1) * LineIntersect(p3, p4, p2) <= 0)
				return true;
			else
				return false;
		}

		//取两线段的交点
		public static function GetCrossLinePoint(p1:Point, p2:Point, p3:Point, p4:Point):Point
		{
			var x1:Number=p1.x;
			var y1:Number=p1.y;
			var x2:Number=p2.x;
			var y2:Number=p2.y;
			var x3:Number=p3.x;
			var y3:Number=p3.y;
			var x4:Number=p4.x;
			var y4:Number=p4.y;
			var d:Number=(y2 - y1) * (x4 - x3) - (y4 - y3) * (x2 - x1);
			var x0:Number=((x2 - x1) * (x4 - x3) * (y3 - y1) + (y2 - y1) * (x4 - x3) * x1 - (y4 - y3) * (x2 - x1) * x3) / d;
			var y0:Number=((y2 - y1) * (y4 - y3) * (x3 - x1) + (x2 - x1) * (y4 - y3) * y1 - (x4 - x3) * (y2 - y1) * y3) / (-d);
			if ((x0 - x1) * (x0 - x2) <= 0 && (x0 - x3) * (x0 - x4) <= 0 && (y0 - y1) * (y0 - y2) <= 0 && (y0 - y3) * (y0 - y4) <= 0)
			{
				return new Point(x0, y0);
			}
			return null;
		}

		//判断两个多边形是否交叉，返回值0,1 
		//0为不相交,1为相交 
		public static function CrossPoly(p1:Array, p2:Array):Boolean
		{
			for (var i:int=0, c:int=p1.length > 2 ? p1.length : 1, p10:Point=p1[p1.length - 1]; i < c; i++, p10=p1[i - 1])
			{
				for (var j:int=0, c2:int=p2.length, p20:Point=p2[p2.length - 1]; j < c2; j++, p20=p2[j - 1])
				{
					if (CrossLine(p10, p1[i], p20, p2[j]))
					{
						return true;
					}
				}
			}
			return false;
		}
		
		//p1的点有一个被包含在p2里面,返回true
		public static function IncludePoly( p1:Array, p2:Array ):Boolean {
			for( var i:int=p1.length-1; i>=0; i-- ) {
				if( IsInsidePolygon( p1[i].x, p1[i].y, p2 ) ) {
					return true;
				}
			}
			return false;
		}

		/**
		 * 射线法判断点q是否在多边形polygon的中
		 * 如果点的射线在多边形内有两个交点： 返回false
		 * 如果点的射线在多边形边上只有一个交点： 返回true
		 */
		public static function IsInsidePolygon(px:Number, py:Number, poly:Array):Boolean
		{
			var angle:Number=0;
			var p1:Point=poly[0];
			for (var i:Number=1; i < poly.length; i++)
			{
				var p2:Point=poly[i];
				var x1:Number=p1.x - px;
				var y1:Number=p1.y - py;
				var x2:Number=p2.x - px;
				var y2:Number=p2.y - py;
				angle+=Angle2D(x1, y1, x2, y2);
				p1=p2;
			}

			if (Math.abs(angle) < Math.PI)
				return false;
			return true;
		}

		public static function Angle2D(x1:Number, y1:Number, x2:Number, y2:Number):Number
		{
			var theta1:Number=Math.atan2(y1, x1);
			var theta2:Number=Math.atan2(y2, x2);
			var dtheta:Number=theta2 - theta1;
			while (dtheta > Math.PI)
				dtheta-=Math.PI * 2;
			while (dtheta < -Math.PI)
				dtheta+=Math.PI * 2;
			return (dtheta);

		}
	    /**
	     * 用基线法判断对象的位置关系
	     * @return destBox在baseBox前返回true,在其后返回false
	     */
	    public static function OrderByBaseLine(destBox:Array, baseBox:Array):Number{
	        var topLinePoint:Point;
	        if (baseBox[3].y >= baseBox[1].y) {
	            topLinePoint = baseBox[1];
	        } else {
	            topLinePoint = baseBox[3];
	        }
	        if (destBox[3].y >= topLinePoint.y && destBox[1].y >= topLinePoint.y) {
	            return 1;
	        }
	        return 0;
	    }
	    /**
	     * 用象限法判断对象的位置关系
	     * @param destBox, baseBox 包围盒顶点集合 [ top, right, bottom, left] ,baseBox为参照物
	     * @param reverse 是否进行反转比较
	     * @return destBox在baseBox前返回1,在其后返回0,未知结果返回-1
	     */
	    public static function OrderByQuadrant( destBox:Array, baseBox:Array, reverse:Boolean=true):Number{
//	    	if( crossPoly( destBox, baseBox ) ) {
//	    		return orderIntersectByQuadrant( destBox, baseBox );
//	    	}
	        var leftSidePoint:Point, rightSidePoint:Point;
	        if (baseBox[0].x >= baseBox[2].x) {
	            rightSidePoint = baseBox[0], leftSidePoint = baseBox[2];
	        } else {
	            rightSidePoint = baseBox[2], leftSidePoint = baseBox[0];
	        }
	        if (destBox[1].x <= rightSidePoint.x) {
	            //左半部分
	            if (destBox[1].y < baseBox[3].y) {
	                //destBox在后，被baseBox遮档
	                return 0;
	            } else {
	                //destBox在前遮档baseBox
	                return 1;
	            }
	        } else if (destBox[3].x >= leftSidePoint.x) {
	            //右半部
	            if (destBox[3].y < baseBox[1].y) {
	                //destBox在后，被baseBox遮档
	                return 0;
	            } else {
	                //destBox在前遮档baseBox
	                return 1;
	            }
	        }
	        //调换对象比较，当destBox太大时，baseBox在他上下两个顶点的x之间时需要调换
	        if (reverse) {
	            var rs:Number = OrderByQuadrant(baseBox, destBox, false);
	            if (rs != -1) {
	                return rs^1;
	            }
	        }
	        return -1;
	    }
	}
}