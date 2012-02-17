package sk.yoz.data.describeTypeST
{
    import flash.utils.describeType;
    import flash.utils.getDefinitionByName;
    import flash.utils.getQualifiedClassName;
    
    import sk.yoz.data.describeTypeST.elements.AbstractEntry;
    import sk.yoz.data.describeTypeST.elements.AbstractFactory;
    import sk.yoz.data.describeTypeST.elements.AbstractProperty;
    import sk.yoz.data.describeTypeST.elements.AbstractType;
    import sk.yoz.data.describeTypeST.elements.Accessor;
    import sk.yoz.data.describeTypeST.elements.Arg;
    import sk.yoz.data.describeTypeST.elements.Constant;
    import sk.yoz.data.describeTypeST.elements.ExtendsClass;
    import sk.yoz.data.describeTypeST.elements.Factory;
    import sk.yoz.data.describeTypeST.elements.ImplementsInterface;
    import sk.yoz.data.describeTypeST.elements.Metadata;
    import sk.yoz.data.describeTypeST.elements.Method;
    import sk.yoz.data.describeTypeST.elements.Parameter;
    import sk.yoz.data.describeTypeST.elements.TypeClass;
    import sk.yoz.data.describeTypeST.elements.TypeInstance;
    import sk.yoz.data.describeTypeST.elements.Variable;

    public class Descriptor
    {
        protected var cachedTypeClasses:Object = {};
        protected var cachedTypeInstances:Object = {};
        
        public function describe(value:Object):AbstractType
        {
            return value is Class
                ? describeClass(value as Class)
                : describeInstance(value);
        }
        
        public function describeClass(constructor:Class):TypeClass
        {
            var className:String = getQualifiedClassName(constructor);
            if(cachedTypeClasses.hasOwnProperty(className))
                return cachedTypeClasses[className];
            
            var description:XML = describeType(constructor);
            return getTypeClass(description, constructor, className);
        }
        
        public function describeInstance(instance:Object):TypeInstance
        {
            var constructor:Class = Object(instance).constructor;
            var className:String = getQualifiedClassName(constructor);
            if(cachedTypeInstances.hasOwnProperty(className))
                return cachedTypeInstances[className];
            
            var description:XML = describeType(instance);
            return getTypeInstance(description, constructor, className);
        }
        
        public function describeClassName(value:String):TypeClass
        {
            if(value == "")
                return null;
            if(cachedTypeClasses.hasOwnProperty(value))
                return cachedTypeClasses[value];
            var constructor:Class = customGetDefinitionByName(value) as Class;
            return constructor ? describeClass(constructor) : null;
        }
        
        protected function customGetDefinitionByName(name:String):Object
        {
            if(name == "*")
                return Object;
            if(name == "__AS3__.vec::Vector.<*>")
                return Vector.<*>;
            if(name == "void")
                return null;
            var result:Object;
            try
            {
                // e.g. builtin.as$0::MethodClosure throws error
                result = getDefinitionByName(name);
            }
            catch(error:Error){}
            return result;
        }
        
        protected function getTypeClass(data:XML, constructor:Class, className:String):TypeClass
        {
            var result:TypeClass = cachedTypeClasses[className] = new TypeClass;
            assignAbstractType(result, data);
            result.factory = getFactory(data.factory[0]);
            result.constant = getConstantList(data.constant);
            result._constructor = constructor;
            return result;
        }
        
        protected function getTypeInstance(data:XML, constructor:Class, className:String):TypeInstance
        {
            var result:TypeInstance = cachedTypeInstances[className] = new TypeInstance;
            assignAbstractType(result, data);
            result._constructor = constructor;
            return result;
        }
        
        protected function getExtendsClassList(list:XMLList):Vector.<ExtendsClass>
        {
            if(!list.length())
                return null;
            var result:Vector.<ExtendsClass> = new Vector.<ExtendsClass>;
            for each(var item:XML in list)
                result.push(getExtendsClass(item));
            return result;
        }
        
        protected function getExtendsClass(data:XML):ExtendsClass
        {
            var result:ExtendsClass = new ExtendsClass;
            result.type = describeClassName(data.@type);
            return result;
        }
        
        protected function getAccessorList(list:XMLList):Vector.<Accessor>
        {
            if(!list.length())
                return null;
            var result:Vector.<Accessor> = new Vector.<Accessor>;
            for each(var item:XML in list)
                result.push(getAccessor(item));
            return result;
        }
        
        protected function getAccessor(data:XML):Accessor
        {
            var result:Accessor = new Accessor;
            assignAbstractProperty(result, data);
            result.access = data.@access;
            result.declaredBy = describeClassName(data.@declaredBy);
            return result;
        }
        
        protected function getMethodList(list:XMLList):Vector.<Method>
        {
            if(!list.length())
                return null;
            var result:Vector.<Method> = new Vector.<Method>;
            for each(var item:XML in list)
                result.push(getMethod(item));
            return result;
        }
        
        protected function getMethod(data:XML):Method
        {
            var result:Method = new Method;
            assignAbstractEntry(result, data);
            result.declaredBy = describeClassName(data.@declaredBy);
            result.returnType = describeClassName(data.@returnType);
            result.parameter = getParameterList(data.parameter);
            return result;
        }
        
        protected function getFactory(data:XML):Factory
        {
            if(!data)
                return null;
            var result:Factory = new Factory;
            result.type = describeClassName(data.@type);
            assignAbstractFactory(result, data);
            return result;
        }
        
        protected function getVariableList(list:XMLList):Vector.<Variable>
        {
            if(!list.length())
                return null;
            var result:Vector.<Variable> = new Vector.<Variable>;
            for each(var item:XML in list)
                result.push(getVariable(item));
            return result;
        }
        
        protected function getVariable(data:XML):Variable
        {
            var result:Variable = new Variable;
            assignAbstractProperty(result, data);
            return result;
        }
        
        protected function getMetadataList(list:XMLList):Vector.<Metadata>
        {
            if(!list.length())
                return null;
            var result:Vector.<Metadata> = new Vector.<Metadata>;
            for each(var item:XML in list)
                result.push(getMetadata(item));
            return result;
        }
        
        protected function getMetadata(data:XML):Metadata
        {
            var result:Metadata = new Metadata;
            result.name = data.@name;
            result.arg = getArgList(data.arg);
            return result;
        }
        
        protected function getArgList(list:XMLList):Vector.<Arg>
        {
            if(!list.length())
                return null;
            var result:Vector.<Arg> = new Vector.<Arg>;
            for each(var item:XML in list)
                result.push(getArg(item));
            return result;
        }
        
        protected function getArg(data:XML):Arg
        {
            var result:Arg = new Arg;
            result.key = data.@key;
            result.value = data.@value;
            return result;
        }
        
        protected function getParameterList(list:XMLList):Vector.<Parameter>
        {
            if(!list.length())
                return null;
            var result:Vector.<Parameter> = new Vector.<Parameter>;
            for each(var item:XML in list)
                result.push(getParameter(item));
            return result;
        }
        
        protected function getParameter(data:XML):Parameter
        {
            var result:Parameter = new Parameter;
            result.index = data.@index;
            result.type = describeClassName(data.@type);
            result.optional = data.@optional == "true";
            return result;
        }
        
        protected function getConstantList(list:XMLList):Vector.<Constant>
        {
            if(!list.length())
                return null;
            var result:Vector.<Constant> = new Vector.<Constant>;
            for each(var item:XML in list)
                result.push(getConstant(item));
            return result;
        }
        
        protected function getConstant(data:XML):Constant
        {
            var result:Constant = new Constant;
            assignAbstractProperty(result, data);
            return result;
        }
        
        protected function getImplementsInterfaceList(list:XMLList):Vector.<ImplementsInterface>
        {
            if(!list.length())
                return null;
            var result:Vector.<ImplementsInterface> = new Vector.<ImplementsInterface>;
            for each(var item:XML in list)
                result.push(getImplementsInterface(item));
            return result;
        }
        
        protected function getImplementsInterface(data:XML):ImplementsInterface
        {
            var result:ImplementsInterface = new ImplementsInterface;
            result.type = describeClassName(data.@type);
            return result;
        }
        
        protected function assignAbstractType(target:AbstractType, data:XML):void
        {
            assignAbstractFactory(target, data);
            target.name = data.@name;
            target.base = describeClassName(data.@base);
            target.isDynamic = data.@isDynamic == "true";
            target.isFinal = data.@isFinal == "true";
            target.isStatic = data.@isStatic == "true";
        }
        
        protected function assignAbstractFactory(target:AbstractFactory, data:XML):void
        {
            target.extendsClass = getExtendsClassList(data.extendsClass);
            target.implementsInterface = getImplementsInterfaceList(data.implementsInterface);
            target.variable = getVariableList(data.variable);
            target.accessor = getAccessorList(data.accessor);
            target.method = getMethodList(data.method);
            target.metadata = getMetadataList(data.metadata);
        }
        
        protected function assignAbstractProperty(target:AbstractProperty, data:XML):void
        {
            assignAbstractEntry(target, data);
            target.type = describeClassName(data.@type);
        }
        
        protected function assignAbstractEntry(target:AbstractEntry, data:XML):void
        {
            target.name = data.@name;
            target.metadata = getMetadataList(data.metadata);
        }
    }
}