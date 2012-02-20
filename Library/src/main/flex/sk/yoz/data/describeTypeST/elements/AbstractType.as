package sk.yoz.data.describeTypeST.elements
{
    public class AbstractType extends AbstractFactory
    {
        public var name:String;
        public var base:Class;
        public var isDynamic:Boolean;
        public var isFinal:Boolean;
        public var isStatic:Boolean;
        
        public var _base:TypeClass;
    }
}