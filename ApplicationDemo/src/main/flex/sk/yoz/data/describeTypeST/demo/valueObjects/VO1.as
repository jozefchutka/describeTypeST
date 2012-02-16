package sk.yoz.data.describeTypeST.demo.valueObjects
{
    [Event(name="added", type="starling.events.Event")]
    
    public dynamic class VO1
    {
        [Bindable]
        public var pString:String = "";
        public var pInt:int = 0;
        public var pUint:uint = 1;
        public var pBoolean:Boolean = true;
        public var pClass:Class = VO1;
        public var pObject:Object = {};
        public var pDate:Date = new Date;
        public var pArray:Array = [];
        public var pVector:Vector.<Object> = new Vector.<Object>;
        public var pVO1:VO1;
        
        public static var psString:String = "";
        public static const psdString:String = "";
        
        [Bindable]
        public function get gsBoolean():Boolean
        {
            return true;
        }
        
        public function set gsBoolean(value:Boolean):void
        {
            
        }
        
        public function get gBoolean():Boolean
        {
            return true;
        }
        
        public function set sBoolean(value:Boolean):void
        {
        }
        
        public function fBooleanIntVoid(a1:Boolean, a2:int):void
        {
            
        }
        
        [Bindable(event="haha")]
        public function fStringBoolean(a1:String):Boolean
        {
            return true;
        }
        
        public function fStringRestArray(a1:String, ...rest):Array
        {
            return null;
        }
        
        public static function psfVoid():void
        {
        }
        
        public static function get psfgString():String
        {
            return "";
        }
    }
}