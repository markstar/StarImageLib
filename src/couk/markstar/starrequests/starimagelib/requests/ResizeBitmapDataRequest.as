package couk.markstar.starrequests.starimagelib.requests
{
	import couk.markstar.starrequests.requests.AbstractRequest;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	
	/**
	 * A request to perform smooth resizing of BitmapData
	 * @author markstar
	 */
	public class ResizeBitmapDataRequest extends AbstractRequest
	{
		/**
		 * @private
		 */
		protected var _bitmapData:BitmapData;
		/**
		 * @private
		 */
		protected var _ratio:Number;
		
		/**
		 * @param bitmapData the BitmapData to be resized
		 * @param ratio the ratio to resize the BitmapData by as a percentage. i.e. to reduce the BitmapData by 50% enter 0.5 as the ratio.
		 */
		public function ResizeBitmapDataRequest( bitmapData:BitmapData, ratio:Number )
		{
			_bitmapData = bitmapData;
			_ratio = ratio;
			
			super();
			
			_completed = new Signal( BitmapData );
		}
		
		/**
		 * The instance of the completed signal for this request
		 * @return An implementation of ISignal. Listeners to the completed signal require BitmapData as a parameter.
		 * @example The following code demonstrates a listener for the completed signal:
		 * <listing version="3.0">
		   protected function completedListener( bitmapData:BitmapData ):void
		   {
		   // function implementation
		   }
		   </listing>
		 */
		override public function get completed():ISignal
		{
			return super.completed;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function send():void
		{
			super.send();
			
			resampleBitmapData();
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function cleanup():void
		{
			_bitmapData.dispose();
			_bitmapData = null;
			
			super.cleanup();
		}
		
		/**
		 * @private
		 */
		protected function resampleBitmapData():void
		{
			_progress.dispatch( 1 );
			
			if( _ratio >= 1 )
			{
				_completed.dispatch( resizeBitmapData( _bitmapData, _ratio ) );
			}
			else
			{
				var bitmapData:BitmapData = _bitmapData.clone();
				var appliedRatio:Number = 1;
				
				do
				{
					if( _ratio < 0.5 * appliedRatio )
					{
						bitmapData = resizeBitmapData( bitmapData, 0.5 );
						appliedRatio = 0.5 * appliedRatio;
					}
					else
					{
						bitmapData = resizeBitmapData( bitmapData, _ratio / appliedRatio );
						appliedRatio = _ratio;
					}
				} while( appliedRatio != _ratio );
				
				_completed.dispatch( bitmapData );
			}
			
			cleanup();
		}
		
		/**
		 * @private
		 */
		protected function resizeBitmapData( bmp:BitmapData, ratio:Number ):BitmapData
		{
			var bmpData:BitmapData = new BitmapData( Math.round( bmp.width * ratio ), Math.round( bmp.height * ratio ) );
			var scaleMatrix:Matrix = new Matrix( bmpData.width / bmp.width, 0, 0, bmpData.height / bmp.height, 0, 0 );
			var colorTransform:ColorTransform = new ColorTransform();
			bmpData.draw( bmp, scaleMatrix, colorTransform, null, null, true );
			
			return ( bmpData );
		}
	}
}