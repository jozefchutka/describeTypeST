package sk.yoz.data.describeTypeST.demo.valueObjects
{
    [Bindable]
    public final class VO2 extends VO1
    {
        [Embed(source="/image.png")]
        public static const IMAGE_CLASS:Class;
        
        protected var abc:String = "";
        
        [Event(name="added", type="starling.events.Event")]
        private var def:Boolean;
        
        public function VO2()
        {
        }
        
        [Bindable(event="change")]
        public function get bindableGetter():String
        {
            return null;
        }
    }
}