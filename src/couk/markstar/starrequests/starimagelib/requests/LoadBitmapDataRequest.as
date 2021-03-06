package couk.markstar.starrequests.starimagelib.requests
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	
	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	import couk.markstar.starrequests.requests.AbstractRequest;
	
	/**
	 * A request to load BitmapData from an image file.
	 * @author markstar
	 */
	public class LoadBitmapDataRequest extends AbstractRequest
	{
		protected var _loader:Loader;
		protected var _url:String;
		
		/**
		 * @param url The URL of the image file to load. Only image file types that are natively support by the Flash player are currently supported.
		 */
		public function LoadBitmapDataRequest( url:String )
		{
			_url = url;
			
			super();
			
			_completed = new Signal( BitmapData );
			
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener( ProgressEvent.PROGRESS, progressListener );
			_loader.contentLoaderInfo.addEventListener( Event.COMPLETE, completeListener );
			_loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, ioErrorListener );
		}
		
		/**
		 * The instance of the completed signal for this request
		 * @return An implementation of ISignal. Listeners to the completed signal require a Bitmap as a parameter.
		 * @example The following code demonstrates a listener for the completed signal:
		 * <listing version="3.0">
		   protected function completedListener( bitmap:Bitmap ):void
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
			
			_loader.load( new URLRequest( _url ) );
		}
		
		/**
		 * @inheritDoc
		 */
		public override function cancel():void
		{
			_loader.close();
			
			super.cancel();
		}
		
		/**
		 * @private
		 */
		override protected function cleanup():void
		{
			_loader.contentLoaderInfo.removeEventListener( ProgressEvent.PROGRESS, progressListener );
			_loader.contentLoaderInfo.removeEventListener( Event.COMPLETE, completeListener );
			_loader.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, ioErrorListener );
			_loader = null;
			_url = null;
			
			super.cleanup();
		}
		
		/**
		 * @private
		 */
		protected function progressListener( e:ProgressEvent ):void
		{
			_progress.dispatch( e.bytesLoaded / e.bytesTotal );
		}
		
		/**
		 * @private
		 */
		protected function completeListener( e:Event ):void
		{
			_progress.dispatch( 1 );
			
			_completed.dispatch( Bitmap( _loader.content ).bitmapData );
			
			cleanup();
		}
		
		/**
		 * @private
		 */
		protected function ioErrorListener( e:IOErrorEvent ):void
		{
			dispatchFailed( e.text );
		}
	}
}