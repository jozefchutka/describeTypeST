package sk.yoz.data.describeTypeST.elements
{
    public class Method extends AbstractEntry
    {
        public var declaredBy:Class;
        public var returnType:Class;
        public var parameter:Vector.<Parameter>;
        
        public var _declaredBy:TypeClass;
        public var _returnType:TypeClass;
    }
}