package sk.yoz.data.describeTypeST.demo
{
    import flash.utils.getQualifiedClassName;
    
    import mx.collections.ArrayCollection;
    import mx.collections.IList;
    
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
        private var isVector:Boolean;
        
        public function DataProxy(source:Object, name:String=null)
        {
            this.source = source;
            sourceConstructor = Descriptor.getConstructorByInstance(source);
            this.name = name;
            this.type = descriptor.describe(source);
            this.factory = type is TypeClass ? TypeClass(type).factory : type;
            isVector = getQualifiedClassName(source).indexOf("::Vector.") > -1;
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
            
            var result:Array = [];
            var item:Object;
            var dynamicChildren:Vector.<DataProxy> = addDynamicChildren();
            for each(item in dynamicChildren)
                result.push(item);
            
            var variables:Vector.<Object> = addVariables();
            var accessors:Vector.<Object> = addAccessors();
            variables = variables.concat(accessors);
            variables.sort(sort);
            for each(item in variables)
                result.push(item);
            
            var methods:Vector.<Object> = addMethods();
            methods.sort(sort);
            for each(item in methods)
                result.push(item);
            
            _children = new ArrayCollection(result);
            return _children;
        }
        
        private function addDynamicChildren():Vector.<DataProxy>
        {
            var target:Vector.<DataProxy> = new Vector.<DataProxy>;
            for(var key:* in source)
            {
                var value:* = source[key];
                if(sourceConstructor == Array || isVector)
                    target.push(new DataProxy(value, "[" + key + "]"));
                else
                    target.push(new DataProxy(value, key));
            }
            return target;
        }
        
        private function addAccessors():Vector.<Object>
        {
            var target:Vector.<Object> = new Vector.<Object>;
            if(!factory.accessor)
                return target;
            
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
            return target;
        }
        
        private function addVariables():Vector.<Object>
        {
            var target:Vector.<Object> = new Vector.<Object>;
            if(!factory.variable)
                return target;
            for each(var variable:Variable in factory.variable)
                addAbstractProperty(target, variable);
            return target;
        }
        
        private function addMethods():Vector.<Object>
        {
            var target:Vector.<Object> = new Vector.<Object>;
            if(!factory.method)
                return target;
            for each(var method:Method in factory.method)
                target.push(new DataProxy(source[method.name], method.name));
            return target;
        }
        
        private function addAbstractProperty(target:Vector.<Object>, property:AbstractProperty):void
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
            else if(isVector)
                labelItems.push(getQualifiedClassName(source) + " (" + source.length +")");
            else if(source is IList)
                labelItems.push(getQualifiedClassName(source) + " (" + source.length +")");
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
        
        private function sort(a:*, b:*):int
        {
            return (a.label < b.label) ? -1 : 1;
        }
    }
}