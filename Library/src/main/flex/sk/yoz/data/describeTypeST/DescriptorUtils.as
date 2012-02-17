package sk.yoz.data.describeTypeST
{
    import sk.yoz.data.describeTypeST.elements.AbstractEntry;
    import sk.yoz.data.describeTypeST.elements.AbstractFactory;
    import sk.yoz.data.describeTypeST.elements.AbstractType;
    import sk.yoz.data.describeTypeST.elements.ExtendsClass;
    import sk.yoz.data.describeTypeST.elements.ImplementsInterface;
    import sk.yoz.data.describeTypeST.elements.Metadata;
    import sk.yoz.data.describeTypeST.elements.TypeClass;

    public class DescriptorUtils
    {
        public static function getExtends(type:AbstractType):Vector.<Class>
        {
            var source:AbstractFactory = type is TypeClass ? TypeClass(type).factory : type;
            var result:Vector.<Class> = new Vector.<Class>;
            for each(var extendsClass:ExtendsClass in source.extendsClass)
                result.push(extendsClass.type._constructor);
            return result;
        }
        
        public static function getImplementations(type:AbstractType):Vector.<Class>
        {
            var source:AbstractFactory = type is TypeClass ? TypeClass(type).factory : type;
            var result:Vector.<Class> = new Vector.<Class>;
            for each(var implementsInterface:ImplementsInterface in source.implementsInterface)
                result.push(implementsInterface.type._constructor);
            return result;
        }
        
        public static function getEntries(type:AbstractType):Vector.<AbstractEntry>
        {
            var source:AbstractFactory = type is TypeClass ? TypeClass(type).factory : type;
            var result:Vector.<AbstractEntry> = new Vector.<AbstractEntry>;
            var entry:AbstractEntry;
            if(source.accessor)
                for each(entry in source.accessor)
                    result.push(entry);
            if(source.variable)
                for each(entry in source.variable)
                    result.push(entry);
            if(source.method)
                for each(entry in source.method)
                    result.push(entry);
            return result;
        }
        
        public static function getEntriesWithMetadata(type:AbstractType, filter:Function):Vector.<AbstractEntry>
        {
            var source:AbstractFactory = type is TypeClass ? TypeClass(type).factory : type;
            var result:Vector.<AbstractEntry> = new Vector.<AbstractEntry>;
            var entry:AbstractEntry;
            if(source.accessor)
                for each(entry in source.accessor)
                    addEntryMetadata(result, entry, filter);
            if(source.variable)
                for each(entry in source.variable)
                    addEntryMetadata(result, entry, filter);
            if(source.method)
                for each(entry in source.method)
                    addEntryMetadata(result, entry, filter);
            return result;
        }
        
        private static function addEntryMetadata(target:Vector.<AbstractEntry>, entry:AbstractEntry, filter:Function):void
        {
            var list:Vector.<Metadata> = entry.metadata;
            if(!list)
                return;
            for each(var metadata:Metadata in list)
            {
                if(filter(entry, metadata))
                {
                    target.push(entry);
                    return;
                }
            }
        }
        
        public static function getClassMetadata(type:AbstractType, filter:Function):Vector.<Metadata>
        {
            var source:AbstractFactory = type is TypeClass ? TypeClass(type).factory : type;
            var result:Vector.<Metadata> = new Vector.<Metadata>;
            var metadata:Metadata;
            addClassMetadata(result, source, filter);
            for each(var extendsClass:ExtendsClass in source.extendsClass)
                addClassMetadata(result, extendsClass.type.factory, filter);
            return result;
        }
        
        private static function addClassMetadata(target:Vector.<Metadata>, factory:AbstractFactory, filter:Function):void
        {
            var list:Vector.<Metadata> = factory.metadata;
            if(!list)
                return;
            for each(var metadata:Metadata in list)
                if(filter(metadata))
                    target.push(metadata);
        }
    }
}