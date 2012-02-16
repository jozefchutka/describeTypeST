package sk.yoz.data.describeTypeST.elements
{
    public class AbstractType extends AbstractFactory
    {
        public var _constructor:Class;
        
        public var name:String;
        public var base:TypeClass;
        public var isDynamic:Boolean;
        public var isFinal:Boolean;
        public var isStatic:Boolean;
    }
}