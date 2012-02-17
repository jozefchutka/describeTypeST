package sk.yoz.data.describeTypeST.demo
{
    import flash.utils.getQualifiedClassName;
    
    import mx.collections.ArrayCollection;
    
    import sk.yoz.data.describeTypeST.Descriptor;
    import sk.yoz.data.describeTypeST.DescriptorUtils;
    import sk.yoz.data.describeTypeST.elements.AbstractEntry;
    import sk.yoz.data.describeTypeST.elements.AbstractFactory;
    import sk.yoz.data.describeTypeST.elements.AbstractProperty;
    import sk.yoz.data.describeTypeST.elements.AbstractType;
    import sk.yoz.data.describeTypeST.elements.Accessor;
    import sk.yoz.data.describeTypeST.elements.Method;
    import sk.yoz.data.describeTypeST.elements.TypeClass;
    import sk.yoz.data.describeTypeST.elements.Variable;
    import sk.yoz.data.describeTypeST.enums.AccessorType;
    
    import spark.collections.Sort;
    import spark.collections.SortField;
    
    public class DataProxy
    {
        private static const descriptor:Descriptor = new Descriptor;
        
        public var name:String;
        public var label:String;
        private var _children:ArrayCollection;
        
        private var type:AbstractType;
        private var source:*;
        private var sourceConstructor:Class;
        private var factory:AbstractFactory;
        private var entries:Vector.<AbstractEntry>;
        
        public function DataProxy(source:Object, name:String=null)
        {
            this.source = source;
            sourceConstructor = Object(source).constructor;
            this.name = name;
            this.type = descriptor.describe(source);
            this.factory = type is TypeClass ? TypeClass(type).factory : type;
            entries = DescriptorUtils.getEntries(type);
            label = labelBySource();
        }
        
        public function get hasChildren():Boolean
        {
            if(source is Function)
                return false;
            if(sourceConstructor == String)
                return false;
            if(factory.accessor && factory.accessor.length)
                return true;
            if(factory.variable && factory.variable.length)
                return true;
            if(factory.method && factory.method.length)
                return true;
            for each(var item:* in source)
                return true;
            return false;
        }
        
        public function get children():ArrayCollection
        {
            if(_children)
                return _children;
                
            var children:Array = [];
            addDynamicChildren(children);
            addVariables(children);
            addAccessors(children);
            addMethods(children);
            if(children.length)
            {
                _children = new ArrayCollection(children);
                sort(_children);
            }
            return _children;
        }
        
        private function addDynamicChildren(target:Array):void
        {
            for(var key:* in source)
            {
                var value:* = source[key];
                var constructor:Class = Object(source).constructor;
                if(constructor == Array)
                    target.push(new DataProxy(value, "[" + key + "]"));
                else if(constructor == Vector.<*>)
                    target.push(new DataProxy(value, "[" + key + "]"));
                else
                    target.push(new DataProxy(value, key));
            }
        }
        
        private function addAccessors(target:Array):void
        {
            if(!factory.accessor)
                return;
            
            var value:*, isError:Boolean;
            for each(var accessor:Accessor in factory.accessor)
            {
                isError = false;
                if(accessor.access == AccessorType.WRITEONLY)
                {
                    target.push(fakeItem(accessor.name, "<setter>"));
                    continue;
                }
                
                try
                {
                    value = source[accessor.name];
                }
                catch(error:Error)
                {
                    target.push(fakeItem(accessor.name, "<exception thrown by getter>"));
                    isError = true;
                }
                
                if(!isError)
                    addAbstractProperty(target, accessor);
            }
        }
        
        private function addVariables(target:Array):void
        {
            if(!factory.variable)
                return;
            for each(var variable:Variable in factory.variable)
                addAbstractProperty(target, variable);
        }
        
        private function addMethods(target:Array):void
        {
            if(!factory.method)
                return;
            
            for each(var method:Method in factory.method)
                target.push(new DataProxy(source[method.name], method.name));
        }
        
        private function addAbstractProperty(target:Array, property:AbstractProperty):void
        {
            var value:* = source[property.name];
            target.push(value == null 
                ? fakeItem(property.name, property.type._constructor, null)
                : new DataProxy(source[property.name], property.name));
        }
        
        private function labelBySource():String
        {
            var labelItems:Array = [];
            name && labelItems.push(name);
            
            if(source === undefined)
                labelItems.push("undefined");
            else if(source === null)
                labelItems.push("null");
            else if(source is Function)
                labelItems.push("Function (" + source.length + ")");
            else if(sourceConstructor == String)
                labelItems.push("String", '"' + source + '"');
            else if(sourceConstructor == uint)
                labelItems.push("uint", source);
            else if(sourceConstructor == int)
                labelItems.push("int", source);
            else if(sourceConstructor == Number)
                labelItems.push("Number", source);
            else if(sourceConstructor == Boolean)
                labelItems.push("Boolean", source);
            else if(sourceConstructor == Class)
                labelItems.push("Class", source);
            else if(sourceConstructor == Array)
                labelItems.push("Array (" + source.length +")");
            else if(sourceConstructor == Vector.<*>)
                labelItems.push(getQualifiedClassName(source) + "(" + source.length +")");
            else
                labelItems.push(source);
            return joinLabelItems(labelItems);
        }
        
        private function labelByValues(...labelItems):String
        {
            var result:Array = labelItems.concat();
            for(var i:uint = 0; i < result.length; i++)
            {
                if(Object(result[i]).constructor == Class)
                    result[i] = getQualifiedClassName(result[i]);
                else if(result[i] == null)
                    result[i] = "null";
            }
            return joinLabelItems(result);
        }
        
        private function joinLabelItems(list:Array):String
        {
            return list.join(" : ");
        }
        
        private function fakeItem(...labelItems):Object
        {
            return {label:labelByValues.apply(this, labelItems)};
        }
        
        private function sort(list:ArrayCollection):void
        {
            var sort:Sort = new Sort();
            sort.fields = [new SortField("label")];
            list.sort = sort;
            list.refresh();
        }
    }
}